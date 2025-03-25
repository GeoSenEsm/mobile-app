class LocationModel {
  final String? surveyParticipationId;
  final bool relatedToSurvey;
  final DateTime dateTime;
  final double latitude;
  final double longitude;
  final bool sentToServer;
  final double? accuracyMeters;

  LocationModel(
      {this.surveyParticipationId,
      this.relatedToSurvey = false,
      required this.dateTime,
      required this.longitude,
      required this.latitude,
      required this.sentToServer,
      this.accuracyMeters});
}
