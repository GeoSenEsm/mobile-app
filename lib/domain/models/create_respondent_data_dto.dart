import 'package:json_annotation/json_annotation.dart';

part 'create_respondent_data_dto.g.dart';

@JsonSerializable()
class CreateRespondentDataDto {
  String? gender;
  int? ageCategoryId;
  int? occupationCategoryId;
  int? educationCategoryId;
  int? greeneryAreaCategoryId;
  int? medicationUseId;
  int? healthConditionId;
  int? stressLevelId;
  int? lifeSatisfactionId;
  int? qualityOfSleepId;

  CreateRespondentDataDto(
      {this.gender,
      this.ageCategoryId,
      this.occupationCategoryId,
      this.educationCategoryId,
      this.greeneryAreaCategoryId,
      this.medicationUseId,
      this.healthConditionId,
      this.stressLevelId,
      this.lifeSatisfactionId,
      this.qualityOfSleepId});

  factory CreateRespondentDataDto.fromJson(Map<String, dynamic> json) =>
      _$CreateRespondentDataDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateRespondentDataDtoToJson(this);
}
