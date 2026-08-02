import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SensorBindKeyStore {
  final FlutterSecureStorage _storage;

  const SensorBindKeyStore({
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) : _storage = storage;

  Future<void> write(
      String sensorTypeCode, String? sensorId, String bindKeyHex) async {
    final normalized = bindKeyHex.toLowerCase();
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(normalized)) {
      throw const InvalidSensorBindKeyException();
    }
    await _storage.write(
      key: _key(sensorTypeCode, sensorId),
      value: normalized,
    );
  }

  Future<List<int>?> read(String sensorTypeCode, String? sensorId) async {
    final value = await _storage.read(key: _key(sensorTypeCode, sensorId));
    if (value == null) return null;
    if (!RegExp(r'^[0-9a-f]{32}$').hasMatch(value)) {
      await delete(sensorTypeCode, sensorId);
      return null;
    }
    return List<int>.generate(
      16,
      (index) =>
          int.parse(value.substring(index * 2, index * 2 + 2), radix: 16),
      growable: false,
    );
  }

  Future<void> delete(String sensorTypeCode, String? sensorId) =>
      _storage.delete(key: _key(sensorTypeCode, sensorId));

  String _key(String sensorTypeCode, String? sensorId) =>
      'sensor-bind-key:$sensorTypeCode:${sensorId ?? ''}';
}

class InvalidSensorBindKeyException implements Exception {
  const InvalidSensorBindKeyException();

  @override
  String toString() => 'Invalid sensor bind key';
}
