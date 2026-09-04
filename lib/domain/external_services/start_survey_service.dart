import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/start_survey_question.dart';

abstract class StartSurveyService{
  Future<APIResponse<List<StartSurveyQuestion>>> getStartSurvey();
}