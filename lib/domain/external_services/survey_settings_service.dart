import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

abstract class SurveySettingsService {
  Future<APIResponse<SurveySettings>> getSettings();
}
