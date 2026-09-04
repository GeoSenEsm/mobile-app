import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/sensors_data_service.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';

class SensorsDataServiceImpl extends APIServiceBase
    implements SensorsDataService {
  SensorsDataServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<void>> create(List<SensorData> dto) {
    return postMany('/api/sensordata', dto.map((e) => e.toJson()).toList());
  }
}
