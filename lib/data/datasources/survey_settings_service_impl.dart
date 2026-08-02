import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/survey_settings_service.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

class SurveySettingsServiceImpl extends APIServiceBase
    implements SurveySettingsService {
  SurveySettingsServiceImpl(super.dio, {super.tokenProvider});

  @override
  Future<APIResponse<SurveySettings>> getSettings() {
    return get<SurveySettings>(
      '/api/surveysettings',
      (dynamic json) => SurveySettings.fromJson(json as Map<String, dynamic>),
    );
  }

  @override
  Future<APIResponse<MobileSensorSetup>> getMobileSensorSetup() {
    return get<MobileSensorSetup>(
      '/api/surveysettings/sensordata/mobile',
      (dynamic json) =>
          MobileSensorSetup.fromJson(json as Map<String, dynamic>),
    );
  }
}
