import 'package:survey_frontend/domain/models/login_dto.dart';
import 'api_response.dart';

abstract class LoginService{
  Future<APIResponse<String>> login(LoginDto loginDto);
}