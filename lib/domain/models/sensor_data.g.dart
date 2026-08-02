// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorData _$SensorDataFromJson(Map<String, dynamic> json) => SensorData(
      dateTime: json['dateTime'] as String,
      source: json['source'] as String,
      values: (json['values'] as List<dynamic>)
          .map((e) => SensorDataValue.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorDataToJson(SensorData instance) =>
    <String, dynamic>{
      'dateTime': instance.dateTime,
      'source': instance.source,
      'values': instance.values.map((e) => e.toJson()).toList(),
    };

SensorDataValue _$SensorDataValueFromJson(Map<String, dynamic> json) =>
    SensorDataValue(
      parameterCode: json['parameterCode'] as String,
      value: json['value'] as String,
    );

Map<String, dynamic> _$SensorDataValueToJson(SensorDataValue instance) =>
    <String, dynamic>{
      'parameterCode': instance.parameterCode,
      'value': instance.value,
    };
