import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/start_survey_service.dart';
import 'package:survey_frontend/domain/models/start_survey_question.dart';

class StartSurveyServiceImpl extends APIServiceBase
    implements StartSurveyService {
  StartSurveyServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<List<StartSurveyQuestion>>> getStartSurvey() =>
      get<List<StartSurveyQuestion>>(
          '/api/qualityofsleep',
          (dynamic items) => items
              .map<StartSurveyQuestion>((e) => StartSurveyQuestion.fromJson(e))
              .toList());
}
