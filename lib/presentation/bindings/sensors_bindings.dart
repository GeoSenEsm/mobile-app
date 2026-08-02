import 'package:get/get.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';
import 'package:survey_frontend/presentation/controllers/sensors_controller.dart';

class SensorsBindings extends Bindings
{
  @override
  void dependencies() {
    Get.lazyPut(() => SensorsController(
      Get.find(), Get.find<SensorMacService>()
    ), fenix: true);
  }

}
