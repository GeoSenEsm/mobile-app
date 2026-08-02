class SensorKind {
  static String get none => 'none';
  static String get manual => 'manual';
  static String get xiaomi => 'xiaomi';
  static String get kestrelDrop2 => 'kestrelDrop2';

  static bool usesBluetooth(String? kind) =>
      kind == xiaomi || kind == kestrelDrop2;
}
