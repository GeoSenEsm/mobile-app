import 'package:json_annotation/json_annotation.dart';
import 'package:survey_frontend/domain/models/create_question_answer_dto.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

part 'create_survey_response_dto.g.dart';

@JsonSerializable()
class CreateSurveyResponseDto {
  final String surveyId;
  final String startDate;
  late final String finishDate;
  SensorData? sensorData;
  List<CreateQuestionAnswerDto> answers;

  CreateSurveyResponseDto(
      {required this.surveyId,
      required this.startDate,
      required this.answers,
      required this.sensorData});

  factory CreateSurveyResponseDto.fromJson(Map<String, dynamic> json) =>
      _$CreateSurveyResponseDtoFromJson(json);
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = _$CreateSurveyResponseDtoToJson(this);
    return json;
  }
}
