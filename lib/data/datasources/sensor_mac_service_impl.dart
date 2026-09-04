import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';
import 'package:survey_frontend/domain/models/assigned_sensor_mac.dart';

class SensorMacServiceImpl extends APIServiceBase implements SensorMacService {
  SensorMacServiceImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<AssignedSensorMac>> getAssignedSensor() {
    return get(
      "/api/sensormac/assigned",
      (dynamic json) =>
          AssignedSensorMac.fromJson(json as Map<String, dynamic>),
    );
  }
}
