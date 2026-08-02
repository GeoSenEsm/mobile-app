import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/change_password_dto.dart';

abstract class ChangePasswordService {
  Future<APIResponse> changePassword(ChangePasswordDto dto);
}