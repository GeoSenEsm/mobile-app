import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

abstract class SendSensorsDataUsecase {
  Future<bool> readAndSendSensorData();
  Future<bool> sendSensorData(SensorsResponse? sensorResponse);
}

class SendSensorsDataUsecaseImpl extends SendSensorsDataUsecase {
  final GetStorage _storage;
  final SensorsDataService _service;
  final SensorConnectionFactory _sensorConnectionFactory;

  SendSensorsDataUsecaseImpl(
      this._storage, this._service, this._sensorConnectionFactory);

  @override
  Future<bool> readAndSendSensorData() async {
    try {
      final sensorConnection = await _sensorConnectionFactory.getSensorConnection(const Duration(seconds: 60));
      return _sendSensorDataFromConnection(sensorConnection);
    } on GetSensorConnectionException catch (_) {
      return false;
    }
  }

  Future<bool> _sendSensorDataFromConnection(SensorConnection connection) async {
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
      var allSensorsData =
          _storage.read<List<dynamic>>('rememberedSensorsData');
      allSensorsData ??= [];

      if (sensorResponse != null) {
        final json = sensorResponse.toJson();
        json['dateTime'] = DateTime.now().toUtc().toIso8601String();
        allSensorsData.add(json);
        _storage.write('rememberedSensorsData', allSensorsData);
      }

      final submitResult = await _service
          .create(allSensorsData.map((e) => SensorData.fromJson(e)).toList());

      if (submitResult.statusCode == 201) {
        await _storage.remove('rememberedSensorsData');
      }

      return true;
    } catch (e) {
      Sentry.captureException(e);
      return false;
    }
  }
}
