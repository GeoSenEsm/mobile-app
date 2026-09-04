import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/accept_privacy_policy_controller.dart';

class AcceptPrivacyPolicyBindings extends Bindings{
  @override
  void dependencies() {
    Get.lazyPut(() => AcceptPrivacyPolicyController(Get.find()));
  }
}