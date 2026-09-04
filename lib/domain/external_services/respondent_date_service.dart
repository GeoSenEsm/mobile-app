import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/create_respondent_data_dto.dart';
import 'package:survey_frontend/domain/models/respondent_data_dto.dart';

abstract class RespondentDataService{
  Future<APIResponse<RespondentDataDto>> create(CreateRespondentDataDto dto);
  Future<APIResponse<RespondentDataDto>> getRespondentData();
}