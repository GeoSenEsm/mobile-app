// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PrivacySettings _$PrivacySettingsFromJson(Map<String, dynamic> json) =>
    PrivacySettings(
      allowLocationTracking: json['allowLocationTracking'] as bool,
      allowLocationTrackingFrom: PrivacySettings._timeOfDayFromJson(
          json['allowLocationTrackingFrom'] as String),
      allowLocationTrackingTo: PrivacySettings._timeOfDayFromJson(
          json['allowLocationTrackingTo'] as String),
    );

Map<String, dynamic> _$PrivacySettingsToJson(PrivacySettings instance) =>
    <String, dynamic>{
      'allowLocationTracking': instance.allowLocationTracking,
      'allowLocationTrackingFrom':
          PrivacySettings._timeOfDayToJson(instance.allowLocationTrackingFrom),
      'allowLocationTrackingTo':
          PrivacySettings._timeOfDayToJson(instance.allowLocationTrackingTo),
    };
