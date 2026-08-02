class SensorKind {
  static String get none => 'none';
  static String get manual => 'manual';
  static String get xiaomi => 'xiaomi';
  static String get kestrel => 'kestrel';
  static String get kestrelDrop2 => kestrel;

  static bool usesBluetooth(String? kind) =>
      kind != null && kind != none && kind != manual;

  static String fromTypeCode(String? code) {
    if (code == null || code.isEmpty) {
      throw const UnknownSensorKindException();
    }
    return code;
  }
}

class UnknownSensorKindException implements Exception {
  final String? sensorTypeCode;

  const UnknownSensorKindException([this.sensorTypeCode]);
}
