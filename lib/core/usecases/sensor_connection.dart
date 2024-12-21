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
