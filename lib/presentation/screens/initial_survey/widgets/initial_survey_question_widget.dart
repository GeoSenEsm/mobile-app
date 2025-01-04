import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/domain/models/initial_survey_question.dart';
import 'package:survey_frontend/domain/models/initial_survey_response.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InitialSurveyQuestionWidget extends StatefulWidget {
  final String question;
  final InitialSurveyQuestionResponse questionResponse;
  final List<InitialSurveyOption> possibleOptions;

  const InitialSurveyQuestionWidget(
      {super.key,
      required this.question,
      required this.questionResponse,
      required this.possibleOptions});

  @override
  State<StatefulWidget> createState() {
    return _InitialSurveyQuestionState();
  }
}

class _InitialSurveyQuestionState extends State<InitialSurveyQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            widget.question,
            style: const TextStyle(fontSize: 30),
          ),
        ),
        ...List<Widget>.from(
            widget.possibleOptions.map((option) => RadioListTile(
                title: Text(option.content),
                value: option.id,
                groupValue: widget.questionResponse.optionId,
                onChanged: (value) {
                  setState(() {
                    widget.questionResponse.optionId = value;
                  });
                })))
      ],
    );
  }

  String? validateNotEmpty(InitialSurveyOption? value) {
    if (value == null) {
      return AppLocalizations.of(Get.context!)!.valueNotEmpty;
    }
    return null;
  }
}
