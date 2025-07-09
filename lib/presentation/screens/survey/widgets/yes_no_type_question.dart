import 'package:flutter/material.dart';
import 'package:survey_frontend/domain/models/create_question_answer_dto.dart';
import 'package:survey_frontend/l10n/app_localizations.dart';

class YesNoTypeQuestion extends StatefulWidget {
  final CreateQuestionAnswerDto createQuestionAnswerDto;
  const YesNoTypeQuestion({super.key, required this.createQuestionAnswerDto});

  @override
  State<StatefulWidget> createState() {
    return _YesNoTypeQuestionState();
  }
}

class _YesNoTypeQuestionState extends State<YesNoTypeQuestion> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio<bool>(
          value: true,
          groupValue: widget.createQuestionAnswerDto.yesNoAnswer,
          onChanged: (value) {
            setState(() {
              widget.createQuestionAnswerDto.yesNoAnswer = value!;
            });
          },
        ),
        Text(AppLocalizations.of(context)!.yes),
        const SizedBox(width: 40),
        Radio<bool>(
          value: false,
          groupValue: widget.createQuestionAnswerDto.yesNoAnswer,
          onChanged: (bool? value) {
            setState(() {
              widget.createQuestionAnswerDto.yesNoAnswer = value!;
            });
          },
        ),
        Text(AppLocalizations.of(context)!.no),
      ],
    );
  }
}
