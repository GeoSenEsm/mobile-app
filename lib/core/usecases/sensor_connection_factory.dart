import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';

class SensorConnectionFactory {
  final GetStorage _storage;

  SensorConnectionFactory(this._storage);

  Future<SensorConnection> getSensorConnection(
      Duration scanningDuration) async {
    final selectedSensor = _storage.read<String>('selectedSensor');
    if ((await FlutterBluePlus.adapterState.first) !=
        BluetoothAdapterState.on) {
      throw BluetoothTurnedOffException();
    }

    if (selectedSensor == null || selectedSensor == SensorKind.none) {
      throw SensorNotSpecifiedException();
    }

    final String deviceName = _getDeviceName(selectedSensor);
    final String? xiaomiMac = _storage.read('xiaomiMac');
    Completer<void> completer = Completer<void>();
    BluetoothDevice? device;
    FlutterBluePlus.scanResults.listen((results) async {
      for (final result in results) {
        bool xiaomiMacSpecified =
            xiaomiMac != null && result.device.remoteId.str == xiaomiMac;
        bool otherDevices = xiaomiMac == null &&
            (result.device.platformName == deviceName ||
                result.device.advName == deviceName);

        if (xiaomiMacSpecified || otherDevices) {
          FlutterBluePlus.stopScan();
          if (!completer.isCompleted) {
            device = result.device;
            try {
              completer.complete();
            } catch (e) {
              //ignore when already complited
            }
          }
          break;
        }
      }
    });
    await FlutterBluePlus.startScan(timeout: scanningDuration);
    await Future.any([
      completer.future,
      Future.delayed(const Duration(seconds: 30), () {
        if (!completer.isCompleted) {
          FlutterBluePlus.stopScan();
          completer.complete();
        }
      }),
    ]);

    if (device == null) {
      throw SensorNotFoundException();
    }

    await device!.connect();
    return _getConnectionCore(selectedSensor, device!);
  }

  String _getDeviceName(String sensorKind) {
    if (sensorKind == SensorKind.xiaomi) {
      return "LYWSD03MMC";
    }

    if (sensorKind == SensorKind.kestrelDrop2) {
      final id = _storage.read<Object>('selectedSensorId')?.toString();
      if (id == null) {
        throw SensorNotSpecifiedException();
      }
      return "D2 - $id";
    }

    throw SensorNotSpecifiedException();
  }

  SensorConnection _getConnectionCore(
      String sensorKind, BluetoothDevice connectedDevice) {
    if (sensorKind == SensorKind.xiaomi) {
      return XiaomiSensorConnection(connectedDevice);
    }

    if (sensorKind == SensorKind.kestrelDrop2) {
      return KestrelDrop2Connection(connectedDevice);
    }

    throw SensorNotSpecifiedException();
  }
}

class GetSensorConnectionException implements Exception {}

class SensorNotSpecifiedException implements GetSensorConnectionException {}

class SensorNotFoundException implements GetSensorConnectionException {}

class BluetoothTurnedOffException implements GetSensorConnectionException {}
