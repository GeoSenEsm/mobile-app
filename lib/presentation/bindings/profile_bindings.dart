import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/profile_controller.dart';

class ProfileBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(Get.find(), Get.find()));
  }
  
}