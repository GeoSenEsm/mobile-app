import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/models/assigned_sensor_mac.dart';

abstract class SensorMacService {
  Future<APIResponse<String>> getMacAddress(String sensorId);
  Future<APIResponse<AssignedSensorMac>> getAssignedSensor();
}
