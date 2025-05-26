import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/respondent_date_service.dart';
import 'package:survey_frontend/domain/models/create_respondent_data_dto.dart';
import 'package:survey_frontend/domain/models/respondent_data_dto.dart';

class RespondentDataServiceImpl extends APIServiceBase implements RespondentDataService{
  RespondentDataServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<RespondentDataDto>> create(CreateRespondentDataDto dto) {
    return postAndDeserialize<RespondentDataDto>('/api/respondents', dto.toJson(), (dynamic json) => RespondentDataDto.fromJson(json));
  }

  @override
   Future<APIResponse<RespondentDataDto>> getRespondentData() =>
      get<RespondentDataDto>(
          '/api/respondents',
          (dynamic json) => RespondentDataDto.fromJson(json));
}