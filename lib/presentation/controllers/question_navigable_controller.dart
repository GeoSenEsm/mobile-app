import 'package:get/get.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/models/create_survey_response_dto.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/controllers/home_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/survey_question_screen.dart';

class QuestionNavigableController extends ControllerBase {
  bool isBusy = false;
  late SurveyDto survey;
  late List<QuestionWithSection> questions;
  int questionIndex = -1;
  int questionsCount = 1;
  late CreateSurveyResponseDto responseModel;
  late List<String?> groupsIds;
  late Map<int, int> triggerableSectionActivationsCounts;
  late Future<LocalizationData> localizationData;
  late Future<SensorData?> futureSensorData;
  late SurveyShortInfo surveyShortInfo;

  void navigateToNextQuestion(QuestionNavigationMode mode) async {
    if (isBusy) {
      return;
    }

    try {
      isBusy = true;

      if (!canGoFurther()) {
        return;
      }

      int nextQuestionIndex = _getNextValidQuestionIndex();

      if (nextQuestionIndex == -1) {
        await Get.toNamed('/submitSurvey', arguments: {
          "shortSurveyInfo": surveyShortInfo,
          'responseModel': responseModel,
          "localizationData": localizationData,
          "futureSensorData": futureSensorData
        });
        return;
      }

      int nextQuestionsCount = _getNextQestionsCount(nextQuestionIndex);

      screenFactory() => SurveyQuestionScreen();
      Map<String, dynamic> arguments = {
        'shortSurveyInfo': surveyShortInfo,
        'responseModel': responseModel,
        'survey': survey,
        'questionIndex': nextQuestionIndex,
        'questionsCount': nextQuestionsCount,
        'questions': questions,
        "groups": groupsIds,
        "triggerableSectionActivationsCounts":
            triggerableSectionActivationsCounts,
        "localizationData": localizationData,
        "futureSensorData": futureSensorData
      };

      if (mode == QuestionNavigationMode.top) {
        await Get.to(screenFactory,
            arguments: arguments, preventDuplicates: false);
        return;
      }
      await Get.off(screenFactory,
          arguments: arguments, preventDuplicates: false);
    } finally {
      isBusy = false;
    }
  }

  int _getNextValidQuestionIndex() {
    if (questionIndex == -1){
      final question = questions.firstWhereOrNull((element) => element.canQuestionBeShown(groupsIds, triggerableSectionActivationsCounts));
      if (question == null) {
        return -1;
      }
      return questions.indexOf(question);
    }

    if (questionIndex + questionsCount == questions.length) {
      return -1;
    }

    for (int i = questionIndex + questionsCount; i < questions.length; i++) {
      if (questions[i]
          .canQuestionBeShown(groupsIds, triggerableSectionActivationsCounts)) {
        return i;
      }
      //TODO: extend the cleanup when more question types are added
      responseModel.answers[i].numericAnswer = null;
      responseModel.answers[i].textAnswer = null;
      if (responseModel.answers[i].selectedOptions != null) {
        for (final option in responseModel.answers[i].selectedOptions!){
          option.optionId = null;
        }
      }
      responseModel.answers[i].yesNoAnswer = null;
    }

    return -1;
  }

  int _getNextQestionsCount(int nextQuestionIndex) {
    final firstQuestion = questions[nextQuestionIndex];

    if (!firstQuestion.section.displayOnOneScreen){
      return 1;
    }

    return firstQuestion.section.questions.length;
  }

  bool canGoFurther() {
    return true;
  }

  void readGetArguments() {
    surveyShortInfo = Get.arguments['shortSurveyInfo'];
    survey = Get.arguments['survey'];
    questions = Get.arguments['questions'];
    responseModel = Get.arguments['responseModel'];
    groupsIds = Get.arguments['groups'];
    triggerableSectionActivationsCounts =
        Get.arguments['triggerableSectionActivationsCounts'];
    localizationData = Get.arguments['localizationData'];
    futureSensorData = Get.arguments['futureSensorData'];
  }
}

enum QuestionNavigationMode { off, top }
