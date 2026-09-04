import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/welcome_screen_controller.dart';

class WelcomeScreenBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => WelcomeScreenController(Get.find()));
  }
}