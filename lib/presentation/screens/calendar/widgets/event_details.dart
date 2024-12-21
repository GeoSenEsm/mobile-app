import 'package:flutter/material.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/functions/formatters.dart';

class EventDetails extends StatelessWidget {
  final SurveyCalendarEvent event;

  const EventDetails({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                readOnly: true,
                initialValue: event.surveyName,
                decoration: InputDecoration(
                    label: Text(getAppLocalizations().surveyName)),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                readOnly: true,
                initialValue: dateShortFormat(event.from.toLocal()),
                decoration: InputDecoration(
                    label: Text(getAppLocalizations().start)),
              ),
              const SizedBox(height: 20,),
              TextFormField(
                readOnly: true,
                initialValue: dateShortFormat(event.to.toLocal()),
                decoration: InputDecoration(
                    label: Text(getAppLocalizations().end)),
              )
            ],
          ),
        ));
  }
}
