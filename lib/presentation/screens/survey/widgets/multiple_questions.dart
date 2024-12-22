import 'package:flutter/material.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';
import 'package:survey_frontend/presentation/screens/survey/widgets/require_scroll_down_view.dart';

class MultipleQuestions extends StatelessWidget {
  final List<Question> questions;
  final Widget Function(Question, int) questionWidgetBuilder;
  final String surveyName;
  final int firstQuestionIndex;
  final void Function()? onScrolledDown;

  const MultipleQuestions(
      {super.key,
      required this.questions,
      required this.questionWidgetBuilder,
      required this.surveyName,
      required this.firstQuestionIndex,
      this.onScrolledDown});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RequireScrollDownView(
        onScrolledDown: onScrolledDown,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
          const SizedBox(height: 20),
          Center(
            child: Text(
              surveyName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 30),
          ..._buildQuestions()
        ]),
      ),
    );
  }

  List<Widget> _buildQuestions() {
    List<Widget> output = [];

    for (int i = 0; i < questions.length; i++) {
      final idx = i + firstQuestionIndex;
      output.add(Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(questions[i].content,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            questionWidgetBuilder(questions[i], idx),
          ],
        ),
      ));
    }

    return output;
  }
}
