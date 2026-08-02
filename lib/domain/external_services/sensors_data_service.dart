import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

abstract class SensorsDataService {
  Future<APIResponse<void>> create(List<SensorData> dto);
}
