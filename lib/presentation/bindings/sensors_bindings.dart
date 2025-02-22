import 'package:get/get.dart';
import 'package:survey_frontend/data/datasources/xiaomi_mac_impl.dart';
import 'package:survey_frontend/domain/external_services/sensor_mac_service.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/presentation/controllers/sensors_controller.dart';

class SensorsBindings extends Bindings
{
  @override
  void dependencies() {
    Get.lazyPut<SensorMacService>(() => XiaomiMacImpl(
      Get.find(), tokenProvider: Get.find<TokenProvider>()
    ), fenix: true);

    Get.lazyPut(() => SensorsController(
      Get.find(), Get.find()
    ), fenix: true);
  }

}