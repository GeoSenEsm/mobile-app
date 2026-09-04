import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/privacy_settings_controller.dart';

class PrivacySettingsBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PrivacySettingsController(Get.find()));
  }
}
