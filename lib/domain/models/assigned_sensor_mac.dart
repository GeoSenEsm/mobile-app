class AssignedSensorMac {
  final String sensorId;
  final String sensorMac;
  final String? sensorTypeCode;

  const AssignedSensorMac({
    required this.sensorId,
    required this.sensorMac,
    this.sensorTypeCode,
  });

  factory AssignedSensorMac.fromJson(Map<String, dynamic> json) {
    return AssignedSensorMac(
      sensorId: json['sensorId'] as String,
      sensorMac: json['sensorMac'] as String,
      sensorTypeCode: json['sensorTypeCode'] as String?,
    );
  }
}
