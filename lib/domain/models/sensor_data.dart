import 'package:json_annotation/json_annotation.dart';

part 'sensor_data.g.dart';

@JsonSerializable()
class SensorData {
  // This should be in UTC ISO8601.
  final String dateTime;
  final String source;
  final List<SensorDataValue> values;

  SensorData({
    required this.dateTime,
    required this.source,
    required this.values,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) =>
      _$SensorDataFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataToJson(this);
}

@JsonSerializable()
class SensorDataValue {
  final String parameterCode;
  final String value;

  SensorDataValue({
    required this.parameterCode,
    required this.value,
  });

  factory SensorDataValue.fromJson(Map<String, dynamic> json) =>
      _$SensorDataValueFromJson(json);
  Map<String, dynamic> toJson() => _$SensorDataValueToJson(this);
}
