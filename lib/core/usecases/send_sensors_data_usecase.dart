import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/app_state.dart';
import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/ble_advertisement_decoder.dart';
import 'package:survey_frontend/core/usecases/sensor_assignment_planner.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/core/usecases/sensor_data_mapper.dart';
import 'package:survey_frontend/core/usecases/sensor_profile_resolver.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

abstract class SendSensorsDataUsecase {
  Future<bool> readAndSendSensorData(Duration connectionTimeout);
  Future<bool> sendSensorData(SensorReading? sensorResponse);
  Future<List<SensorData>> readSensorData();
  List<SensorDataValue> valuesFromResponse(SensorReading sensorResponse);
}

class SendSensorsDataUsecaseImpl extends SendSensorsDataUsecase {
  final DatabaseHelper _databaseHelper;
  final SensorsDataService _service;
  final SensorConnectionFactory _sensorConnectionFactory;
  final GetStorage _storage;
  final AppState _appState;
  final SensorAssignmentPlanner _planner;
  final Connectivity _connectivity = Connectivity();

  SendSensorsDataUsecaseImpl(this._databaseHelper, this._service,
      this._sensorConnectionFactory, this._storage, this._appState,
      this._planner);

  @override
  Future<bool> readAndSendSensorData(Duration connectionTimeout) async {
    try {
      if (_storage.read<String>(MobileSensorSetup.sensorModeKey) ==
          MobileSensorSetup.noSensorData) {
        return true;
      }
      final setup = _planner.readSetup();
      final assignments = _planner.orderedAssignments(setup);
      if (assignments.isEmpty) {
        return await sendSensorData(null);
      }

      // Every enabled sensor is attempted, not just the first one that connects, so each
      // reports its own independent SensorData row (see SensorData.source's single-sensor-type
      // foreign key on the backend — there is no combined-sensor row to merge into).
      var anySent = false;
      for (final assignment in assignments) {
        if (assignment.sensorTypeCode == 'manual') {
          continue;
        }
        final bleState = await FlutterBluePlus.adapterState.first;
        if (bleState == BluetoothAdapterState.on) {
          try {
            final sensorConnection =
                await _sensorConnectionFactory.getSensorConnection(
              _planner.timeoutFor(setup, assignment),
              sensorTypeCode: assignment.sensorTypeCode,
              sensorId: assignment.sensorId,
              sensorMac: assignment.sensorMac,
            );
            if (await _sendSensorDataFromConnection(sensorConnection)) {
              anySent = true;
            }
          } on Exception {
            continue;
          }
        }
      }
      return anySent ? true : await sendSensorData(null);
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
        final values = valuesFromResponse(sensorResponse);
        if (values.isEmpty) {
          return false;
        }
        final now = DateTime.now().toUtc();
        if (_appState.isSurveyActive) {
          // Attribute this reading to the open survey instead of sending it as ambient data.
          // Recorded per source, so a survey with several connected sensor types keeps one
          // reading from each instead of the latest sensor silently replacing the others.
          _appState.currentSurveySensorData.record(SensorData(
              dateTime: now.toIso8601String(),
              source: sensorResponse.source,
              values: values));
          return true;
        }
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
  List<SensorDataValue> valuesFromResponse(SensorReading sensorResponse) {
    return SensorDataMapper.fromResponse(sensorResponse, _planner.readSetup());
  }

  @override
  Future<List<SensorData>> readSensorData() async {
    try {
      final mode = _storage.read<String>(MobileSensorSetup.sensorModeKey);
      final selectedSensor = _storage.read<String>('selectedSensor');
      if (mode == MobileSensorSetup.noSensorData ||
          selectedSensor == SensorKind.none ||
          selectedSensor == SensorKind.manual) {
        return [];
      }
      final setup = _planner.readSetup();
      final assignments = _planner
          .orderedAssignments(setup)
          .where((assignment) => assignment.sensorTypeCode != 'manual')
          .toList();
      if (assignments.isEmpty) {
        return [];
      }

      // Every assignment is attempted concurrently, the same way the manual Sensors screen does
      // it (see SensorDataController.startScanning) — SensorConnectionFactory only serializes
      // attempts that target the *same* sensor type, so unrelated sensor types connect in
      // parallel instead of summing their timeouts, and one slow/unreachable sensor no longer
      // blocks the others from being read. Each source is mapped through SensorDataMapper against
      // its own wired parameters, so the resulting rows are already scoped per source.
      final results = await Future.wait(
          assignments.map((assignment) => _readOneSensor(setup, assignment)));
      return results.whereType<SensorData>().toList();
    } on GetSensorConnectionException catch (_) {
      return [];
    } catch (e) {
      Sentry.captureException(e);
      return [];
    }
  }

  Future<SensorData?> _readOneSensor(
      MobileSensorSetup? setup, RespondentSensorAssignment assignment) async {
    SensorConnection? connection;
    try {
      connection = await _sensorConnectionFactory.getSensorConnection(
        _planner.timeoutFor(setup, assignment),
        sensorTypeCode: assignment.sensorTypeCode,
        sensorId: assignment.sensorId,
        sensorMac: assignment.sensorMac,
      );
      final response = await connection.getSensorData();
      final values = SensorDataMapper.fromResponse(response, setup);
      if (values.isEmpty) {
        return null;
      }
      return SensorData(
          dateTime: DateTime.now().toUtc().toIso8601String(),
          source: response.source,
          values: values);
    } on GetSensorConnectionException {
      // Not found / busy / Bluetooth off / not specified for this one assignment — the other
      // concurrently-attempted sensors are unaffected.
      return null;
    } on UnsupportedSensorException {
      return null;
    } on AdvertisementPacketException {
      // The advertisement transport's equivalent of SensorNotFoundException: no matching,
      // decodable broadcast turned up in time.
      return null;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    } finally {
      await connection?.dispose();
    }
  }
}
