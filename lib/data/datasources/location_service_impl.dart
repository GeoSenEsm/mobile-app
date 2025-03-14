import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/location_service.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';

class LocalizationServiceImpl extends APIServiceBase
    implements LocalizationService {
  LocalizationServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<String>> submitLocation(LocalizationData location) {
    return postMany<String>('/api/localization', [location.toJson()]);
  }

  @override
  Future<APIResponse> submitLocations(List<LocalizationData> locations) {
    return postMany(
        '/api/localization', locations.map((e) => e.toJson()).toList());
  }
}
