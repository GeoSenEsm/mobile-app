import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:survey_frontend/domain/usecases/token_validity_checker.dart';

class TokenValidityCheckerImpl implements TokenValidityChecker{
  @override
  bool isValid(String token) {
    try{
      return !JwtDecoder.isExpired(token);
    } on FormatException{
      return false;
    }
  }
}