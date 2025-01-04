import 'package:get/get.dart';
import 'package:survey_frontend/core/usecases/create_question_answer_dto_factory.dart';
import 'package:survey_frontend/data/datasources/respondent_group_service_impl.dart';
import 'package:survey_frontend/data/datasources/short_survey_service_impl.dart';
import 'package:survey_frontend/domain/external_services/respondent_group_service.dart';
import 'package:survey_frontend/domain/external_services/short_survey_service.dart';
import 'package:survey_frontend/presentation/controllers/home_controller.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortSurveyService>(() => ShortSurveyServiceImpl(
        Get.find(), Get.find(),
        tokenProvider: Get.find()));
    Get.lazyPut<CreateQuestionAnswerDtoFactory>(
        () => CreateQuestionAnswerDtoFactoryImpl());
    Get.lazyPut<HomeController>(() => HomeController(Get.find(), Get.find(),
        Get.find(), Get.find(), Get.find(), Get.find(), Get.find(), Get.find()));
  }
}
