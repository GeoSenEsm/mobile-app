class SensorKind {
  static String get none => 'none';
  static String get manual => 'manual';
  static String get xiaomi => 'xiaomi';
  static String get kestrelDrop2 => 'kestrelDrop2';

  static bool usesBluetooth(String? kind) =>
      kind == xiaomi || kind == kestrelDrop2;

  /// Maps API {@code sensor_type.code} to the local storage value.
  static String fromTypeCode(String? code) {
    switch (code) {
      case 'kestrel':
        return kestrelDrop2;
      case 'manual':
        return manual;
      case 'none':
        return none;
      case 'xiaomi':
      default:
        return xiaomi;
    }
  }
}
