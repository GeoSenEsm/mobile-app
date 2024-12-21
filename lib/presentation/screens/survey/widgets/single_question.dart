import 'package:flutter/material.dart';
import 'package:survey_frontend/domain/models/survey_dto.dart';

class SingleQuestion extends StatelessWidget {
  final Question question;
  final Widget Function(Question, int) questionWidgetBuilder;
  final String surveyName;
  final int questionIndex;

  const SingleQuestion(
      {super.key, required this.question, required this.questionWidgetBuilder, required this.surveyName, required this.questionIndex});

  @override
  Widget build(BuildContext context) {
   return  Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Center(
              child: Text(
                surveyName,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(question.content,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
                child: SingleChildScrollView(
                    child: questionWidgetBuilder(question, questionIndex)))
          ],
        );
  }
}
