import 'package:flutter/material.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/require_scroll_down_view.dart';

class SingleQuestion extends StatelessWidget {
  final Question question;
  final Widget Function(Question, int) questionWidgetBuilder;
  final String surveyName;
  final int questionIndex;
  final void Function()? onScrolledDown;

  const SingleQuestion(
      {super.key,
      required this.question,
      required this.questionWidgetBuilder,
      required this.surveyName,
      required this.questionIndex,
      this.onScrolledDown});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text(
            surveyName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 30),
        Center(
          child: Text(
            question.content,
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
            child: RequireScrollDownView(
          onScrolledDown: onScrolledDown,
          child: questionWidgetBuilder(question, questionIndex),
        ))
      ],
    );
  }
}