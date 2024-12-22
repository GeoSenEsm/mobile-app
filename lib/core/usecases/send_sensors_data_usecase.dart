import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

abstract class SendSensorsDataUsecase {
  Future<bool> readAndSendSensorData();
  Future<bool> sendSensorData(SensorsResponse? sensorResponse);
}

class SendSensorsDataUsecaseImpl extends SendSensorsDataUsecase {
  final DatabaseHelper _databaseHelper;
  final SensorsDataService _service;
  final SensorConnectionFactory _sensorConnectionFactory;

  SendSensorsDataUsecaseImpl(
      this._databaseHelper, this._service, this._sensorConnectionFactory);

  @override
  Future<bool> readAndSendSensorData() async {
    try {
      final sensorConnection = await _sensorConnectionFactory
          .getSensorConnection(const Duration(seconds: 60));
      return _sendSensorDataFromConnection(sensorConnection);
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
}
