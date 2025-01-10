import 'package:flutter/material.dart';
import 'package:survey_frontend/domain/models/create_question_answer_dto.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

class TextInputTypeQuestion extends StatefulWidget {
  final CreateQuestionAnswerDto dto;

  const TextInputTypeQuestion({super.key, required this.dto});

  @override
  State<StatefulWidget> createState() {
    return _TextInputTypeQuestionState();
  }
}

class _TextInputTypeQuestionState extends State<TextInputTypeQuestion> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: 150,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration:
          InputDecoration(labelText: getAppLocalizations().enterResponse),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return getAppLocalizations().valueNotEmpty;
        }
        return null;
      },
      onChanged: (value) {
        setState(() {
          widget.dto.textAnswer = value;
        });
      },
    );
  }
}
