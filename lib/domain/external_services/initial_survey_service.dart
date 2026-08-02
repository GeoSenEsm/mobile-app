import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/initial_survey_question.dart';
import 'package:survey_frontend/domain/models/initial_survey_response.dart';

abstract class InitialSurveyService{
  Future<APIResponse<List<InitialSurveyQuestion>>> getInitialSurvey();
  Future<APIResponse> submit(List<InitialSurveyQuestionResponse> response);
  Future<APIResponse<Map<String, dynamic>>> getMyResponse();
}