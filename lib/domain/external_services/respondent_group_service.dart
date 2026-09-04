import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/respondent_group_dto.dart';

abstract class RespondentGroupService {
  Future<APIResponse<List<RespondentGroupDto>>> getAllForRespondent(
      String respondentId);
}
