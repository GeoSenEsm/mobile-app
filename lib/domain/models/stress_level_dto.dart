import 'package:json_annotation/json_annotation.dart';

part 'stress_level_dto.g.dart';

@JsonSerializable()
class StressLevelDto {
  final int id;
  final String display;
  final int rowVersion;

  StressLevelDto(
      {required this.id, required this.display, required this.rowVersion});

  factory StressLevelDto.fromJson(Map<String, dynamic> json) =>
      _$StressLevelDtoFromJson(json);
  Map<String, dynamic> toJson() => _$StressLevelDtoToJson(this);
}
