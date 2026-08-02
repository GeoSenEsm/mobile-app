import 'dart:async';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/gatt_profile_decoder.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';

abstract class SensorConnection {
  Future<SensorReading> getSensorData();
  Future<void> dispose();
}

class GattProfileSensorConnection implements SensorConnection {
  final BluetoothDevice _device;
  final GattProfile _profile;
  final GattProfileDecoder _decoder;
  List<BluetoothService>? _services;
  List<BluetoothCharacteristic>? _characteristics;

  GattProfileSensorConnection(
    this._device,
    this._profile, {
    GattProfileDecoder decoder = const GattProfileDecoder(),
  }) : _decoder = decoder;

  @override
  Future<SensorReading> getSensorData() async {
    await _ensureCharacteristics();
    await _executeActions();
    final packets = <List<int>>[];
    for (var index = 0; index < _characteristics!.length; index++) {
      packets.add(await _acquirePacket(
          _profile.reads[index], _characteristics![index]));
    }
    return _decoder.decode(_profile, packets);
  }

  Future<void> _executeActions() async {
    for (final action in _profile.actions) {
      if (action.type == 'delay') {
        await Future<void>.delayed(
            Duration(milliseconds: action.milliseconds!));
        continue;
      }
      final characteristic =
          _findCharacteristic(action.serviceUuid!, action.characteristicUuid!);
      await characteristic.write(action.value, withoutResponse: false);
    }
  }

  Future<List<int>> _acquirePacket(
      GattRead read, BluetoothCharacteristic characteristic) async {
    if (read.acquisition.mode == 'read') {
      return characteristic.read();
    }

    final completer = Completer<List<int>>();
    var packetsSeen = 0;
    late StreamSubscription<List<int>> subscription;
    Timer? timer;
    subscription = characteristic.onValueReceived.listen(
      (packet) {
        if (completer.isCompleted) return;
        packetsSeen++;
        try {
          _decoder.validateFrame(read, packet);
          completer.complete(List<int>.unmodifiable(packet));
        } on GattPacketException {
          if (packetsSeen >= read.acquisition.maxPackets) {
            completer.completeError(
                const GattPacketException('No valid packet within maxPackets'));
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
      },
    );
    try {
      timer = Timer(
        Duration(milliseconds: read.acquisition.timeoutMilliseconds),
        () {
          if (!completer.isCompleted) {
            completer.completeError(
                const GattPacketException('Notification timed out'));
          }
        },
      );
      await characteristic.setNotifyValue(true);
      return await completer.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      await characteristic.setNotifyValue(false);
    }
  }

  Future<void> _ensureCharacteristics() async {
    if (_characteristics != null) return;
    _services = await _device.discoverServices();
    _characteristics = _profile.reads.map((read) {
      return _findCharacteristic(read.serviceUuid, read.characteristicUuid);
    }).toList(growable: false);
  }

  BluetoothCharacteristic _findCharacteristic(
      String serviceUuidValue, String characteristicUuidValue) {
    final serviceUuid = Guid(serviceUuidValue);
    final characteristicUuid = Guid(characteristicUuidValue);
    final service = _services!.firstWhere(
        (candidate) => candidate.uuid == serviceUuid,
        orElse: () => throw GattServiceNotFoundException(serviceUuidValue));
    return service.characteristics.firstWhere(
      (candidate) => candidate.uuid == characteristicUuid,
      orElse: () =>
          throw GattCharacteristicNotFoundException(characteristicUuidValue),
    );
  }

  @override
  Future<void> dispose() => _device.disconnect();
}

class AdvertisementSensorConnection implements SensorConnection {
  final SensorReading _reading;

  const AdvertisementSensorConnection(this._reading);

  @override
  Future<SensorReading> getSensorData() async => _reading;

  @override
  Future<void> dispose() async {}
}

class GattServiceNotFoundException implements Exception {
  final String uuid;

  const GattServiceNotFoundException(this.uuid);
}

class GattCharacteristicNotFoundException implements Exception {
  final String uuid;

  const GattCharacteristicNotFoundException(this.uuid);
}
