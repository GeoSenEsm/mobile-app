import 'package:flutter/material.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';

class EventTile extends StatelessWidget {
  final SurveyCalendarEvent calendarEvent;

  const EventTile({super.key, required this.calendarEvent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 0, 1, 0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            color: _getTileColor(context)),
        child: Center(
          child: Text(
            calendarEvent.surveyName,
            textAlign: TextAlign.center,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Color _getTileColor(BuildContext context){
    if (calendarEvent.submited) {
      return Colors.green;
    }

    final now = DateTime.now().toUtc();
    if (calendarEvent.to.isBefore(now)){
      return Colors.red;
    }

    return Theme.of(context).cardColor;
  }
}
