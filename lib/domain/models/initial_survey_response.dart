import 'package:json_annotation/json_annotation.dart';

part 'initial_survey_response.g.dart';

@JsonSerializable()
class InitialSurveyQuestionResponse {
  String questionId;
  String? optionId;

  InitialSurveyQuestionResponse(
      {required this.questionId, required this.optionId});

  factory InitialSurveyQuestionResponse.fromJson(Map<String, dynamic> json) =>
      _$InitialSurveyQuestionResponseFromJson(json);

  Map<String, dynamic> toJson() => _$InitialSurveyQuestionResponseToJson(this);
}
