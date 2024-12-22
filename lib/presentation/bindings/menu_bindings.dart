import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_history_controller.dart';
import 'package:survey_frontend/presentation/controllers/menu_controller.dart';

class MenuBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ManuController());
    Get.lazyPut(() => SensorDataHistoryController(Get.find()), fenix: true);
    Get.lazyPut(() => SensorDataController(Get.find(), Get.find()), fenix: true);
  }
}
