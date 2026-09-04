import 'package:get/get.dart';
import 'package:survey_frontend/domain/external_services/initial_survey_service.dart';
import 'package:survey_frontend/domain/models/initial_survey_response.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class WelcomeScreenController extends ControllerBase {
  final InitialSurveyService _initialSurveyService;

  WelcomeScreenController(this._initialSurveyService);

  void letsGo() async {
    final apiResult = await _initialSurveyService.getInitialSurvey();

    if (apiResult.statusCode == 404) {
      await Get.offAllNamed('/home');
      return;
    }

    if (apiResult.error != null || apiResult.statusCode != 200) {
      handleSomethingWentWrong(apiResult.error);
      return;
    }

    if (apiResult.body!.isEmpty) {
      await Get.offAllNamed('/home');
      return;
    }

    final questions = apiResult.body!;
    final responses = {
      for (var question in questions)
        question.id: InitialSurveyQuestionResponse(
            questionId: question.id, optionId: null),
    };

    Get.offAllNamed(Routes.initialSurveyQuestions, arguments: {
      "questions": questions.obs,
      "responsesIdMappings": responses,
      "questionIndexFrom": 0,
      "questionIndexTo": questions.length < 5 ? questions.length - 1 : 4
    });
  }
}
