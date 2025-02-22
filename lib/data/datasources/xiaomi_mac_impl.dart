import 'package:survey_frontend/data/datasources/api_service_base.dart';
import 'package:survey_frontend/domain/external_services/api_response.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';

class XiaomiMacImpl extends APIServiceBase implements SensorMacService {
  XiaomiMacImpl(super.dio, {required super.tokenProvider});

  @override
  Future<APIResponse<String>> getMacAddress(String sensorId) {
    return get("/api/sensormac?sensorId=$sensorId",
        (dynamic json) => json["sensorMac"] as String);
  }
}
