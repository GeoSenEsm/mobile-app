import 'package:get/get.dart';
import 'package:survey_frontend/data/datasources/respondent_data_service_impl.dart';
import 'package:survey_frontend/domain/external_services/respondent_date_service.dart';
import 'package:survey_frontend/domain/usecases/token_provider.dart';
import 'package:survey_frontend/presentation/controllers/login_controller.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RespondentDataService>(() => RespondentDataServiceImpl(
        Get.find(),
        tokenProvider: Get.find<TokenProvider>()));
    Get.lazyPut<LoginController>(() => LoginController(
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find(),
      Get.find()
    ));
  }
}