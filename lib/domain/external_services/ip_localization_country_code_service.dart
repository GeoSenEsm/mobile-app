import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/ip_localization.dart';

abstract class IpLocalizationCountryCodeService{
  Future<APIResponse<IpLocalization>> getIpLoclization(String? ip);
}