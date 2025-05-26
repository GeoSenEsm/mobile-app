import 'package:json_annotation/json_annotation.dart';

part 'ip_localization.g.dart';

@JsonSerializable()
class IpLocalization{
  String? status;
  String? countryCode;

  IpLocalization({required this.countryCode, required this.status});

  factory IpLocalization.fromJson(Map<String, dynamic> json) => _$IpLocalizationFromJson(json);

  Map<String, dynamic> toJson() => _$IpLocalizationToJson(this);
}