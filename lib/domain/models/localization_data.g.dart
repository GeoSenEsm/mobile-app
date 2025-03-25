// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'localization_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocalizationData _$LocalizationDataFromJson(Map<String, dynamic> json) =>
    LocalizationData(
      surveyParticipationId: json['surveyParticipationId'] as String?,
      dateTime: json['dateTime'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracyMeters: (json['accuracyMeters'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LocalizationDataToJson(LocalizationData instance) =>
    <String, dynamic>{
      'surveyParticipationId': instance.surveyParticipationId,
      'dateTime': instance.dateTime,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'accuracyMeters': instance.accuracyMeters,
    };
