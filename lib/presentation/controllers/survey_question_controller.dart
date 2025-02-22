import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/core/usecases/survey_images_usecase.dart';
import 'package:survey_frontend/domain/models/question_type.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/discrete_single_option_type_question.dart';
import 'package:survey_frontend/presentation/controllers/question_navigable_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/image_type_question.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/number_input_type_question.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/text_input_type_question.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/text_multiple_choice_type_question.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/text_single_choice_type_question.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/yes_no_type_question.dart';

class SurveyQuestionController extends QuestionNavigableController {
  var answeredQuestionIndexStack = <int>[].obs;
  final SurveyImagesUseCase _surveyImagesUseCase;
  final RxBool hasToScrollDown = RxBool(true);

  SurveyQuestionController(this._surveyImagesUseCase);

  Widget buildQuestionFromType(Question question, int index) {
    switch (question.questionType) {
      case QuestionType.singleChoiceText:
        return TextSingleChoiceTypeQuestion(
            question: question,
            selectedOption: responseModel.answers[index].selectedOptions![0],
            triggerableSectionActivationsCounts:
                triggerableSectionActivationsCounts);
      case QuestionType.singleChoiceLinearScale:
        return DiscreteSingleOptionTypeQuestion(
            dto: responseModel.answers[index],
            from: question.numberRange!.from,
            to: question.numberRange!.to,
            fromLabel: question.numberRange!.fromLabel,
            toLabel: question.numberRange!.toLabel);
      case QuestionType.yesNo:
        return YesNoTypeQuestion(
            createQuestionAnswerDto: responseModel.answers[index]);
      case QuestionType.multipleChoiceText:
        return TextMultipleChoiceTypeQuestion(
            question: question,
            selectedOptions: responseModel.answers[index].selectedOptions!,
            triggerableSectionActivationsCounts:
                triggerableSectionActivationsCounts);
      case QuestionType.numberInput:
        return NumberInputTypeQuestion(dto: responseModel.answers[index]);
      case QuestionType.imageChoice:
        return ImageTypeQuestion(
            question: question,
            selectedOption: responseModel.answers[index].selectedOptions![0],
            surveyImagesUseCase: _surveyImagesUseCase);
      case QuestionType.textInput:
        return TextInputTypeQuestion(dto: responseModel.answers[index]);
      default:
        //TODO decide what to do in this case (most likely skip this question)
        throw Exception('Unsupported question type: ${question.questionType}');
    }
  }

  @override
  void readGetArguments() {
    super.readGetArguments();
    questionIndex = Get.arguments['questionIndex'];
    questionsCount = Get.arguments['questionsCount'];
  }

  void scrolled() {
    hasToScrollDown.value = false;
  }

  @override
  bool canGoFurther() {
    //TODO: REMEMBER ABOUT OTHER QUESTION TYPES IN THE FUTURE
    //TODO: move this logic to validator in each question

    for (int idx = questionIndex;
        idx < questionIndex + questionsCount && idx < questions.length;
        idx++) {
      if (!questions[idx].question.required) {
        continue;
      }

      if (questions[idx].question.questionType ==
          QuestionType.multipleChoiceText) {
        if (responseModel.answers[idx].selectedOptions!.isEmpty) {
          popup("", AppLocalizations.of(Get.context!)!.selectAtLeastOneOption);
          return false;
        }

        continue;
      }

      if (questions[idx].question.questionType ==
          QuestionType.singleChoiceLinearScale) {
        if (responseModel.answers[idx].numericAnswer == null) {
          popup("", AppLocalizations.of(Get.context!)!.selectOneOption);
          return false;
        }

        continue;
      }

      if (questions[idx].question.questionType == QuestionType.yesNo) {
        if (responseModel.answers[idx].yesNoAnswer == null) {
          popup("", AppLocalizations.of(Get.context!)!.selectOneOption);
          return false;
        }

        continue;
      }
      if (questions[idx].question.questionType ==
              QuestionType.singleChoiceText ||
          questions[idx].question.questionType == QuestionType.imageChoice) {
        if (responseModel.answers[idx].selectedOptions![0].optionId == null) {
          popup("", AppLocalizations.of(Get.context!)!.selectOneOption);
          return false;
        }
      }
      if (questions[idx].question.questionType == QuestionType.numberInput) {
        var number = responseModel.answers[idx].numericAnswer;
        if (number == null) {
          return false;
        }
        if (number < 0) {
          return false;
        }
        if (number > 1000) {
          return false;
        }
        continue;
      }
      if (questions[idx].question.questionType == QuestionType.textInput) {
        var text = responseModel.answers[idx].textAnswer;
        if (text == null || text.isEmpty) {
          return false;
        }
        if (text.length > 1000) {
          return false;
        }
        continue;
      }
    }

    return true;
  }
}
