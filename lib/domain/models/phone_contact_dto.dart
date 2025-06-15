import 'package:json_annotation/json_annotation.dart';

part 'phone_contact_dto.g.dart';

@JsonSerializable()
class PhoneContactDto {
  final String id;
  final String name;
  final String number;

  PhoneContactDto(
      {required this.id, required this.name, required this.number});

  factory PhoneContactDto.fromJson(Map<String, dynamic> json) =>
      _$PhoneContactDtoFromJson(json);

  Map<String, dynamic> toJson() => _$PhoneContactDtoToJson(this);
}
