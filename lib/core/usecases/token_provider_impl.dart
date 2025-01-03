import 'package:get_storage/get_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';

class TokenProviderImpl implements TokenProvider{
  final GetStorage _storage;
  
  TokenProviderImpl(this._storage);

  @override
  String? getToken() {
    return _storage.read<String>('apiToken');
  }
  
  @override
  String? getUsername() {
    final token = getToken();

    if (token == null) {
      return null;
    }

    final decoded = JwtDecoder.decode(token);
    return decoded['sub'];
  }

}