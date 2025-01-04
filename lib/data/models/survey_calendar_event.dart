
class SurveyCalendarEvent {
  final String surveyName;
  final String timeSlotId;
  final DateTime from;
  final DateTime to;
  final bool submited;

  SurveyCalendarEvent(
      {required this.surveyName,
      required this.timeSlotId,
      required this.from,
      required this.to,
      required this.submited});
}