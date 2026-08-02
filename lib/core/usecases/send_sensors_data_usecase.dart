import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/core/usecases/sensor_data_mapper.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

abstract class SendSensorsDataUsecase {
  Future<bool> readAndSendSensorData(Duration connectionTimeout);
  Future<bool> sendSensorData(SensorReading? sensorResponse);
  Future<SensorData?> readSensorData();
}

class SendSensorsDataUsecaseImpl extends SendSensorsDataUsecase {
  final DatabaseHelper _databaseHelper;
  final SensorsDataService _service;
  final SensorConnectionFactory _sensorConnectionFactory;
  final GetStorage _storage;
  final Connectivity _connectivity = Connectivity();

  SendSensorsDataUsecaseImpl(this._databaseHelper, this._service,
      this._sensorConnectionFactory, this._storage);

  @override
  Future<bool> readAndSendSensorData(Duration connectionTimeout) async {
    try {
      if (_storage.read<String>(MobileSensorSetup.sensorModeKey) ==
          MobileSensorSetup.noSensorData) {
        return true;
      }
      final setup = _readSetup();
      final assignments = _orderedAssignments(setup);
      if (assignments.isEmpty) {
        return await sendSensorData(null);
      }

      for (final assignment in assignments) {
        if (assignment.sensorTypeCode == 'manual') {
          continue;
        }
        _applyAssignment(assignment);
        final bleState = await FlutterBluePlus.adapterState.first;
        if (bleState == BluetoothAdapterState.on) {
          try {
            final sensorConnection = await _sensorConnectionFactory
                .getSensorConnection(_timeoutFor(setup, assignment));
            final sent = await _sendSensorDataFromConnection(sensorConnection);
            if (sent) {
              return true;
            }
          } on Exception {
            continue;
          }
        }
      }
      return await sendSensorData(null);
    } on GetSensorConnectionException catch (_) {
      return false;
    }
  }

  Future<bool> _sendSensorDataFromConnection(
      SensorConnection connection) async {
    try {
      final data = await connection.getSensorData();
      return await sendSensorData(data);
    } finally {
      await connection.dispose();
    }
  }

  @override
  Future<bool> sendSensorData(SensorReading? sensorResponse) async {
    try {
      if (sensorResponse != null) {
        final values =
            SensorDataMapper.fromResponse(sensorResponse, _readSetup());
        if (values.isEmpty) {
          return false;
        }
        final now = DateTime.now().toUtc();
        final model = SensorDataModel(
            dateTime: now,
            source: sensorResponse.source,
            values: values,
            sentToServer: false);
        await _databaseHelper.addSensorData(model);
      }
      final results = await _connectivity.checkConnectivity();
      if (!results.contains(ConnectivityResult.mobile) &&
          !results.contains(ConnectivityResult.ethernet) &&
          !results.contains(ConnectivityResult.wifi)) {
        return true;
      }
      final allToSend = await _databaseHelper.getAlSensorDataNotSentToServer();
      final submitResult = await _service.create(allToSend
          .map((e) => SensorData(
              dateTime: e.dateTime.toIso8601String(),
              source: e.source,
              values: e.values))
          .toList());

      if (submitResult.statusCode == 201) {
        await _databaseHelper.markAllSensorDataSentToServer();
        return true;
      }

      return false;
    } catch (e) {
      Sentry.captureException(e);
      return false;
    }
  }

  @override
  Future<SensorData?> readSensorData() async {
    try {
      final mode = _storage.read<String>(MobileSensorSetup.sensorModeKey);
      final selectedSensor = _storage.read<String>('selectedSensor');
      if (mode == MobileSensorSetup.noSensorData ||
          selectedSensor == SensorKind.none ||
          selectedSensor == SensorKind.manual) {
        return null;
      }
      final setup = _readSetup();
      final assignments = _orderedAssignments(setup);
      if (assignments.isEmpty) {
        return null;
      }

      for (final assignment in assignments) {
        if (assignment.sensorTypeCode == 'manual') {
          continue;
        }
        _applyAssignment(assignment);
        try {
          final sensorConnection = await _sensorConnectionFactory
              .getSensorConnection(_timeoutFor(setup, assignment));
          try {
            final response = await sensorConnection.getSensorData();
            final values =
                SensorDataMapper.fromResponse(response, _readSetup());
            if (values.isEmpty) {
              continue;
            }
            return SensorData(
                dateTime: DateTime.now().toUtc().toIso8601String(),
                source: response.source,
                values: values);
          } finally {
            await sensorConnection.dispose();
          }
        } on GetSensorConnectionException {
          continue;
        }
      }
      return null;
    } on GetSensorConnectionException catch (_) {
      return null;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    }
  }

  MobileSensorSetup? _readSetup() {
    final raw = _storage.read<String>(MobileSensorSetup.storageKey);
    if (raw == null) {
      return null;
    }
    return MobileSensorSetup.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  List<RespondentSensorAssignment> _orderedAssignments(
      MobileSensorSetup? setup) {
    if (setup == null) return [];
    final enabledTypeCodes = setup.sensorTypes
        .where((t) => t.enabled)
        .map((t) => t.sensorTypeCode)
        .toSet();
    final assignments = setup.assignments
        .where((a) => a.enabled && enabledTypeCodes.contains(a.sensorTypeCode))
        .toList();
    assignments.sort((a, b) => a.priorityOrder.compareTo(b.priorityOrder));
    return assignments;
  }

  Duration _timeoutFor(
      MobileSensorSetup? setup, RespondentSensorAssignment assignment) {
    final typeSetting = setup?.sensorTypes.firstWhere(
      (type) => type.sensorTypeCode == assignment.sensorTypeCode,
      orElse: () => const SensorTypeSetting(
          sensorTypeCode: '',
          sensorTypeName: null,
          enabled: false,
          connectionTimeoutSeconds: 30,
          displayOrder: 0),
    );
    return Duration(seconds: typeSetting?.connectionTimeoutSeconds ?? 30);
  }

  void _applyAssignment(RespondentSensorAssignment assignment) {
    final kind = SensorKind.fromTypeCode(assignment.sensorTypeCode);
    _storage.write('selectedSensor', kind);
    _storage.write('selectedSensorId', assignment.sensorId);
    _storage.write('selectedSensorMac', assignment.sensorMac);
    _storage.remove('xiaomiMac');
  }
}
