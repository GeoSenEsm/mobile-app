
class SurveyCalendarEvent {
  final String surveyName;
  final String timeSlotId;
  final DateTime from;
  final DateTime to;

  SurveyCalendarEvent(
      {required this.surveyName,
      required this.timeSlotId,
      required this.from,
      required this.to});
}