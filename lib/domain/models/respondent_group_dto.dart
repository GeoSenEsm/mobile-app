import 'package:json_annotation/json_annotation.dart';

part 'respondent_group_dto.g.dart';

@JsonSerializable()
class RespondentGroupDto{
  String id;
  String name;

  RespondentGroupDto({required this.id, required this.name});

  factory RespondentGroupDto.fromJson(Map<String, dynamic> json) =>
      _$RespondentGroupDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RespondentGroupDtoToJson(this);
}