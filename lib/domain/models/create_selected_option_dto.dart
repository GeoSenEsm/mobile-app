import 'package:json_annotation/json_annotation.dart';

part 'create_selected_option_dto.g.dart';

@JsonSerializable()
class CreateSelectedOptionDto {
  String? optionId;

  CreateSelectedOptionDto({this.optionId});

  factory CreateSelectedOptionDto.fromJson(Map<String, dynamic> json) =>
      _$CreateSelectedOptionDtoFromJson(json);
  Map<String, dynamic> toJson() => _$CreateSelectedOptionDtoToJson(this);
}
