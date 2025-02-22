// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_survey_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateSurveyResponseDto _$CreateSurveyResponseDtoFromJson(
        Map<String, dynamic> json) =>
    CreateSurveyResponseDto(
      surveyId: json['surveyId'] as String,
      startDate: json['startDate'] as String,
      answers: (json['answers'] as List<dynamic>)
          .map((e) =>
              CreateQuestionAnswerDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      sensorData: json['sensorData'] == null
          ? null
          : SensorData.fromJson(json['sensorData'] as Map<String, dynamic>),
    )..finishDate = json['finishDate'] as String;

Map<String, dynamic> _$CreateSurveyResponseDtoToJson(
        CreateSurveyResponseDto instance) =>
    <String, dynamic>{
      'surveyId': instance.surveyId,
      'startDate': instance.startDate,
      'finishDate': instance.finishDate,
      'sensorData': instance.sensorData,
      'answers': instance.answers,
    };
