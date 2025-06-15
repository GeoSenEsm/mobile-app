// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phone_contact_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhoneContactDto _$PhoneContactDtoFromJson(Map<String, dynamic> json) =>
    PhoneContactDto(
      id: json['id'] as String,
      name: json['name'] as String,
      number: json['number'] as String,
    );

Map<String, dynamic> _$PhoneContactDtoToJson(PhoneContactDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'number': instance.number,
    };
