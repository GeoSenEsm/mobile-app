import 'package:get/get.dart';
import 'package:survey_frontend/data/datasources/change_password_service_impl.dart';
import 'package:survey_frontend/domain/external_services/change_password_service.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/presentation/controllers/change_password_controller.dart';

class ChangePasswordBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChangePasswordService>(() => ChangePasswordServiceImpl(
        Get.find(),
        tokenProvider: Get.find<TokenProvider?>()));
    Get.lazyPut(() => ChangePasswordController(Get.find()));
  }
}
