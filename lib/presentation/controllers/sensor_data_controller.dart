import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SensorDataController extends ControllerBase {
  final Rx<SensorDataState> state = SensorDataState.initial.obs;
  final Rx<SensorReading?> sensorResponse = Rx<SensorReading?>(null);
  final RxList<SensorDataValue> sensorValues = <SensorDataValue>[].obs;
  final RxBool isSendingData = false.obs;
  final SensorConnectionFactory _sensorConnectionFactory;
  final SendSensorsDataUsecase _sendSensorsDataUsecase;
  final SendLocationDataUsecase _sendLocationDataUsecase;
  SensorConnection? _currentConnection;
  bool disconnected = false;

  SensorDataController(this._sensorConnectionFactory,
      this._sendSensorsDataUsecase, this._sendLocationDataUsecase);

  void startScanning() async {
    if (state.value == SensorDataState.scanning) {
      return;
    }

    try {
      state.value = SensorDataState.scanning;
      await disconnect();
      disconnected = false;
      _currentConnection = await _sensorConnectionFactory
          .getSensorConnection(const Duration(seconds: 60));
      state.value = SensorDataState.sensorFound;
      if (disconnected) {
        await disconnect();
        return;
      }
      startReadingValueInBackground();
    } on SensorNotFoundException catch (_) {
      state.value = SensorDataState.sensorNotFound;
    } on BluetoothTurnedOffException catch (_) {
      state.value = SensorDataState.bluetoothTurnedOff;
    } on SensorNotSpecifiedException catch (_) {
      state.value = SensorDataState.sensorNotSpecified;
    } catch (e) {
      state.value = SensorDataState.error;
      Sentry.captureException(e);
    }
  }

  void startReadingValueInBackground() async {
    while (_currentConnection != null) {
      try {
        final reading = await _currentConnection!.getSensorData();
        sensorResponse.value = reading;
        sensorValues.assignAll(
          _sendSensorsDataUsecase.valuesFromResponse(reading),
        );
        await Future.delayed(const Duration(seconds: 5));
      } catch (e) {
        Sentry.captureException(e);
        state.value = SensorDataState.error;
        await disconnect();
      }
    }
  }

  Future<void> disconnect() async {
    disconnected = true;
    if (_currentConnection != null) {
      await _currentConnection!.dispose();
      _currentConnection = null;
      sensorResponse.value = null;
      sensorValues.clear();
    }
  }

  Future<void> sendSensorData() async {
    if (isSendingData.value || sensorResponse.value == null) {
      return;
    }

    if (sensorValues.isEmpty) {
      await popup(AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.sensorReadingCannotBeStored);
      return;
    }

    try {
      isSendingData.value = true;
      final sent =
          await _sendSensorsDataUsecase.sendSensorData(sensorResponse.value!);
      if (!sent) {
        // The setup-mismatch case (no recognized values) was already ruled out by the
        // sensorValues.isEmpty check above, so a false here is a send failure (server
        // rejection, auth, etc.) — show the generic error, not the setup-specific one.
        await handleSomethingWentWrong(null);
        return;
      }
      //can be done in the background, therefore there is no need to await
      _sendLocationDataUsecase.readAndSendLocationData();
    } catch (e) {
      handleSomethingWentWrong(e);
    } finally {
      isSendingData.value = false;
    }
  }

  void sensorHistory() {
    Get.toNamed(Routes.sensorDataHistory);
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
