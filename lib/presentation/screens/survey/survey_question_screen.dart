import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/question_navigable_controller.dart';
import 'package:survey_frontend/presentation/controllers/survey_question_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/multiple_questions.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/next_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/single_question.dart';

class SurveyQuestionScreen extends GetView<SurveyQuestionController> {
  final SurveyQuestionController _controller;

  SurveyQuestionScreen({super.key}) : _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    _controller.readGetArguments();
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'UrBEaT',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildQuestions(),
      ),
      bottomNavigationBar: NextButton(
        nextAction: () {
          _controller.navigateToNextQuestion(QuestionNavigationMode.top);
        },
        hasToScrollDown: _controller.hasToScrollDown,
        child: Text(AppLocalizations.of(context)!.next),
      ),
    );
  }

  Widget _buildQuestions() {
    if (_controller.questionsCount == 1) {
      return SingleQuestion(
        question: _controller.questions[_controller.questionIndex].question,
        questionWidgetBuilder: _controller.buildQuestionFromType,
        surveyName: _controller.survey.name,
        questionIndex: _controller.questionIndex,
        onScrolledDown: _controller.scrolled,
      );
    }

    return MultipleQuestions(
      questions: _controller.questions
          .sublist(_controller.questionIndex,
              _controller.questionIndex + _controller.questionsCount)
          .map((e) => e.question)
          .toList(),
      questionWidgetBuilder: _controller.buildQuestionFromType,
      surveyName: _controller.survey.name,
      firstQuestionIndex: _controller.questionIndex,
      onScrolledDown: _controller.scrolled,
    );
  }
}
