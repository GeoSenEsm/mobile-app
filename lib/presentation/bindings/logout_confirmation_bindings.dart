import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/logout_confirmation_controller.dart';

class LogoutConfirmationBindings extends Bindings {
  @override
  void dependencies() {
    Get.create(
        () => LogoutConfirmationController(Get.find(), Get.find(), Get.find()));
  }
}
