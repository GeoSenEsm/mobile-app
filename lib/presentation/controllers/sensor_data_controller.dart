import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class SensorDataController extends ControllerBase {
  final Rx<SensorDataState> state = SensorDataState.initial.obs;
  final Rx<SensorsResponse?> sensorResponse = Rx<SensorsResponse?>(null);
  final RxBool isSendingData = false.obs;
  final SensorConnectionFactory _sensorConnectionFactory;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  SensorConnection? _currentConnection;

  SensorDataController(this._sensorConnectionFactory, this._sendSensorsDataUsecase);

  void startScanning() async {
    if (state.value == SensorDataState.scanning) {
      return;
    }

    try {
      state.value = SensorDataState.scanning;
      await disconnect();
      _currentConnection = await _sensorConnectionFactory
          .getSensorConnection(const Duration(seconds: 60));
      state.value = SensorDataState.sensorFound;
      startReadingValueInBackground();
    } on SensorNotFoundExcetion catch (_) {
      state.value = SensorDataState.sensorNotFound;
    } on BluetoothTurnedOffException catch (_) {
      state.value = SensorDataState.bluetoothTurnedOff;
    } on SensorNotSpecifiedExeption catch (_) {
      state.value = SensorDataState.sensorNotSpecified;
    } catch (e) {
      state.value = SensorDataState.error;
      Sentry.captureException(e);
    }
  }

  void startReadingValueInBackground() async {
    while (_currentConnection != null) {
      try {
        sensorResponse.value = await _currentConnection!.getSensorData();
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        Sentry.captureException(e);
        state.value = SensorDataState.error;
        await disconnect();
      }
    }
  }

  Future<void> disconnect() async {
    if (_currentConnection != null) {
      await _currentConnection!.dispose();
      _currentConnection = null;
      sensorResponse.value = null;
    }
  }

  Future<void> sendSensorData() async {
    if (isSendingData.value || sensorResponse.value == null){
      return;
    }

    try {
      isSendingData.value = true;
      await _sendSensorsDataUsecase.sendSensorData(sensorResponse.value!);
    } catch (e) {
      handleSomethingWentWrong(e);
    } finally {
      isSendingData.value = false;
    }
  }
}

enum SensorDataState {
  initial,
  scanning,
  bluetoothTurnedOff,
  sensorNotFound,
  sensorNotSpecified,
  sensorFound,
  error
}
