import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/ip_localization_country_code_service.dart';
import 'package:survey_frontend/domain/models/ip_localization.dart';

class IpLocalizationCountryCodeServiceImpl 
extends APIServiceBase 
implements IpLocalizationCountryCodeService{

  IpLocalizationCountryCodeServiceImpl(super.dio);

  @override
  Future<APIResponse<IpLocalization>> getIpLoclization(String? ip) {
    if (ip == null){
      return get<IpLocalization>('http://ip-api.com/json', (dynamic json) => IpLocalization.fromJson(json));
    }
    return get<IpLocalization>('http://ip-api.com/json/$ip', (dynamic json) => IpLocalization.fromJson(json));
  }
}