import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/question_navigable_controller.dart';
import 'package:survey_frontend/presentation/controllers/survey_question_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/next_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                _controller.survey.name,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            //FIXME wyswietlaj numer rozwiazywanego pytanie (nie indeksu pytania)
            const SizedBox(height: 30),
            Center(
              child: Text(
                _controller.question.content,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
                child: SingleChildScrollView(
                    child: _controller
                        .buildQuestionFromType(_controller.question))),
          ],
        ),
      ),
      bottomNavigationBar: NextButton(
          nextAction: () {
            _controller.navigateToNextQuestion(QuestionNavigationMode.top);
          },
          text: AppLocalizations.of(context)!.next),
    );
  }
}
