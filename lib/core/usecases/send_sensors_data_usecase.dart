import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

abstract class SendSensorsDataUsecase {
  Future<bool> readAndSendSensorData(Duration connectionTimeout);
  Future<bool> sendSensorData(SensorsResponse? sensorResponse);
  Future<SensorData?> readSensorData();
}

class SendSensorsDataUsecaseImpl extends SendSensorsDataUsecase {
  final DatabaseHelper _databaseHelper;
  final SensorsDataService _service;
  final SensorConnectionFactory _sensorConnectionFactory;
  final Connectivity _connectivity = Connectivity();

  SendSensorsDataUsecaseImpl(
      this._databaseHelper, this._service, this._sensorConnectionFactory);

  @override
  Future<bool> readAndSendSensorData(Duration connectionTimeout) async {
    try {
      final bleState = await FlutterBluePlus.adapterState.first;
      if (bleState == BluetoothAdapterState.on) {
        final sensorConnection = await _sensorConnectionFactory
            .getSensorConnection(connectionTimeout);
        return await _sendSensorDataFromConnection(sensorConnection);
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
  Future<bool> sendSensorData(SensorsResponse? sensorResponse) async {
    try {
      if (sensorResponse != null) {
        final now = DateTime.now().toUtc();
        final model = SensorDataModel(
            dateTime: now,
            temperature: sensorResponse.temperature,
            humidity: sensorResponse.humidity,
            sentToServer: false);
        await _databaseHelper.addSensorData(model);
      }
      final results = await _connectivity.checkConnectivity();
      if (!results.contains(ConnectivityResult.mobile) && !results.contains(ConnectivityResult.ethernet)
       && !results.contains(ConnectivityResult.wifi)){
        return true;
       }
      final allToSend = await _databaseHelper.getAlSensorDataNotSentToServer();
      final submitResult = await _service.create(allToSend
          .map((e) => SensorData(
              dateTime: e.dateTime.toIso8601String(),
              temperature: e.temperature,
              humidity: e.humidity))
          .toList());

      if (submitResult.statusCode == 201) {
        await _databaseHelper.markAllSensorDataSentToServer();
      }

      return true;
    } catch (e) {
      Sentry.captureException(e);
      return false;
    }
  }

  @override
  Future<SensorData?> readSensorData() async {
    try {
      final sensorConnection = await _sensorConnectionFactory
          .getSensorConnection(const Duration(seconds: 30));
      final response = await sensorConnection.getSensorData();
      return SensorData(
          dateTime: DateTime.now().toUtc().toIso8601String(),
          temperature: response.temperature,
          humidity: response.humidity);
    } on GetSensorConnectionException catch (_) {
      return null;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    }
  }
}
