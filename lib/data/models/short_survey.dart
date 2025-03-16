class SurveyShortInfo {
  final String name;
  final String id;
  DateTime startTime;
  DateTime finishTime;
  final String timeSlotId;
  SurveyShortInfo(
      {required this.name,
      required this.id,
      required this.finishTime,
      required this.startTime,
      required this.timeSlotId});
}
