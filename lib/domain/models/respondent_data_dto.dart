import 'package:json_annotation/json_annotation.dart';

part 'respondent_data_dto.g.dart';

@JsonSerializable()
class RespondentDataDto {
  String id;
  String identityUserId;
  String gender;
  int ageCategoryId;
  int occupationCategoryId;
  int educationCategoryId;
  int greeneryAreaCategoryId;
  int medicationUseId;
  int healthConditionId;
  int stressLevelId;
  int lifeSatisfactionId;
  int qualityOfSleepId;

  RespondentDataDto(
      this.id,
      this.identityUserId,
      this.gender,
      this.ageCategoryId,
      this.occupationCategoryId,
      this.educationCategoryId,
      this.greeneryAreaCategoryId,
      this.medicationUseId,
      this.healthConditionId,
      this.stressLevelId,
      this.lifeSatisfactionId,
      this.qualityOfSleepId);

  factory RespondentDataDto.fromJson(Map<String, dynamic> json) =>
      _$RespondentDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RespondentDataDtoToJson(this);
}
