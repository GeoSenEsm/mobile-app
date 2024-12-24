import 'package:json_annotation/json_annotation.dart';

part 'survey_participation_dto.g.dart';

@JsonSerializable()
class SurveyParticipationDto {
  final String id;
  final String respondentId;
  final String surveyId;
  final String date;
  final int rowVersion;
  final String? surveyStartDate;
  final String? surveyFinishDate;

  SurveyParticipationDto(
      {required this.id,
      required this.respondentId,
      required this.surveyId,
      required this.date,
      required this.rowVersion,
      this.surveyStartDate,
      this.surveyFinishDate});

  factory SurveyParticipationDto.fromJson(Map<String, dynamic> json) =>
      _$SurveyParticipationDtoFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyParticipationDtoToJson(this);
}
