import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/survey_response_service.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/survey_participation_dto.dart';

class SurveyResponseServiceImpl extends APIServiceBase
    implements SurveyResponseService {
  SurveyResponseServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<SurveyParticipationDto>> submitResponse(
          CreateSurveyResponseDto response) =>
      postAndDeserialize<SurveyParticipationDto>(
          '/api/surveyresponses',
          response.toJson(),
          (dynamic obj) => SurveyParticipationDto.fromJson(obj));

  @override
  Future<APIResponse<List<SurveyParticipationDto>>> submitResponses(
      List<CreateSurveyResponseDto> responses) {
    final responsesJson = responses.map((e) => e.toJson()).toList();
    return postManyAndDeserializeMany(
        '/api/surveyresponses/offline',
        responsesJson,
        (dynamic obj) => obj
            .map<SurveyParticipationDto>(
                (e) => SurveyParticipationDto.fromJson(e))
            .toList());
  }
}
