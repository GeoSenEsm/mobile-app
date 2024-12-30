import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:survey_frontend/core/models/sensors_response.dart';

abstract class SensorConnection {
  Future<SensorsResponse> getSensorData();
  Future<void> dispose();
}

class XiaomiSensorConnection implements SensorConnection {
  final BluetoothDevice _device;
  BluetoothCharacteristic? _characteristic;

  XiaomiSensorConnection(this._device);

  @override
  Future<SensorsResponse> getSensorData() async {
    await _ensureCharacteristic();
    final values = await _characteristic!.read();
    final temp = values[0] + values[1] * 256;
    final humidity = values[2];
    return SensorsResponse(
        temperature: temp.toDouble() / 100, humidity: humidity.toDouble());
  }

  Future<void> _ensureCharacteristic() async {
    if (_characteristic != null) {
      return;
    }
    List<BluetoothService> services = await _device.discoverServices();
    final serviceGuid = Guid('ebe0ccb0-7a0a-4b0c-8a1a-6ff2997da3a6');
    final characteristicGuid = Guid('ebe0ccc1-7a0a-4b0c-8a1a-6ff2997da3a6');
    final service = services.firstWhere((e) => e.uuid == serviceGuid);
    _characteristic =
        service.characteristics.firstWhere((e) => e.uuid == characteristicGuid);
  }

  @override
  Future<void> dispose() async {
    await _device.disconnect();
  }
}

class KestrelDrop2Connection implements SensorConnection {
  final BluetoothDevice _device;
  BluetoothCharacteristic? _tempCharacteristic;
  BluetoothCharacteristic? _humidityCharacteristic;

  KestrelDrop2Connection(this._device);

  @override
  Future<void> dispose() async {
    await _device.disconnect();
  }

  @override
  Future<SensorsResponse> getSensorData() async {
    await _ensureCharacteristic();
    final tempValues = await _tempCharacteristic!.read();
    final humValues = await _humidityCharacteristic!.read();

    if (tempValues[0] != 7 || humValues[0] != 7){
      throw KestrelReadingError();
    }

    final temp = tempValues[1] + tempValues[2] * 256;
    final humidity = humValues[1] + humValues[2] * 256;
    return SensorsResponse(
        temperature: temp.toDouble() / 100, humidity: humidity.toDouble() / 100);
  }

  Future<void> _ensureCharacteristic() async {
    if (_tempCharacteristic != null || _humidityCharacteristic != null) {
      return;
    }
    List<BluetoothService> services = await _device.discoverServices();
    final serviceGuid = Guid('12630000-cc25-497d-9854-9b6c02c77054');
    final tempCharacteristicGuid = Guid('12630001-cc25-497d-9854-9b6c02c77054');
    final humidityCharacteristicGuid =
        Guid('12630002-cc25-497d-9854-9b6c02c77054');
    final service = services.firstWhere((e) => e.uuid == serviceGuid);
    _tempCharacteristic = service.characteristics
        .firstWhere((e) => e.uuid == tempCharacteristicGuid);
    _humidityCharacteristic = service.characteristics
        .firstWhere((e) => e.uuid == humidityCharacteristicGuid);
  }
}


class KestrelReadingError extends Error{

}