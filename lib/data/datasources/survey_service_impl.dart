import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/survey_service.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';

class SurveyServiceImpl extends APIServiceBase implements SurveyService {
  SurveyServiceImpl(super.dio);

  @override
  Future<APIResponse<SurveyDto>> getSurvey(String surveyID) => get<SurveyDto>(
      "/api/surveys?surveyId=$surveyID",
      (dynamic json) => SurveyDto.fromJson(json));
}
