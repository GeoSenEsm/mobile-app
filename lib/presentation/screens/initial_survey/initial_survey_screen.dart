import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/domain/models/initial_survey_question.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/initial_survey_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:survey_frontend/presentation/screens/initial_survey/widgets/initial_survey_question_widget.dart';

class InitialSurveyScreen extends GetView<InitialSurveyController> {
  final InitialSurveyController _controller;

  InitialSurveyScreen({super.key}) : _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    _controller.loadGetArguments();
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).padding.top),
            Expanded(
              child: ListView.builder(
                itemCount: _controller.questionIndexTo -
                    _controller.questionIndexFrom +
                    1,
                itemBuilder: (context, index) {
                  final question = _controller
                      .questions[_controller.questionIndexFrom + index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: InitialSurveyQuestionWidget(
                      question: question.content,
                      possibleOptions: question.options,
                      questionResponse:
                          _controller.responsesIdMappings[question.id]!,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, -5))
        ]),
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Obx(() {
                if (_controller.showRequiredErrorMessage.value) {
                  return Text(
                    getAppLocalizations().valueNotEmpty,
                    style: const TextStyle(color: Colors.red),
                  );
                }

                return const SizedBox(
                  height: 0,
                );
              }),
              const SizedBox(
                height: 10,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _controller.next,
                  child: Text(AppLocalizations.of(context)!.next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
