// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ip_localization.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IpLocalization _$IpLocalizationFromJson(Map<String, dynamic> json) =>
    IpLocalization(
      countryCode: json['countryCode'] as String?,
      status: json['status'] as String?,
    );

Map<String, dynamic> _$IpLocalizationToJson(IpLocalization instance) =>
    <String, dynamic>{
      'status': instance.status,
      'countryCode': instance.countryCode,
    };
