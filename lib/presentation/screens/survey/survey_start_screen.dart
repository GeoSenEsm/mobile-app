import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/question_navigable_controller.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/next_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyStartScreen extends GetView<QuestionNavigableController> {
  final QuestionNavigableController _controller;

  SurveyStartScreen({super.key}) : _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    _controller.readGetArguments();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Text(
                AppLocalizations.of(context)!.initializeSurveyQuestion,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NextButton(
          nextAction: () {
            _controller.navigateToNextQuestion(QuestionNavigationMode.off);
          },
          hasToScrollDown: false.obs,
          child: Text(AppLocalizations.of(context)!.start),),
    );
  }
}
