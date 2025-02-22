import 'package:survey_frontend/domain/external_services/api_response.dart';

abstract class SensorMacService {
  Future<APIResponse<String>> getMacAddress(String sensorId);
}
