import 'package:survey_frontend/domain/models/sensor_data.dart';

class AppState {
  bool justSubmitedSurvey = false;

  /// True from the moment a survey is opened until the respondent returns to
  /// the home screen (submitted or backed out). While true, any sensor
  /// reading obtained by the background task or the manual Sensors screen is
  /// attributed to the survey (see [currentSurveySensorData]) instead of
  /// being sent as ambient data.
  bool isSurveyActive = false;

  /// The sensor readings currently attributed to the active survey — one entry per sensor
  /// *source*, so a survey with several connected sensor types keeps a reading from each
  /// instead of the latest one silently replacing the rest. A fresher reading from the same
  /// source still replaces its own prior entry (see [SurveySensorReadings.record]).
  final SurveySensorReadings currentSurveySensorData = SurveySensorReadings();
}

/// A small source-keyed collection instead of a bare `List<SensorData>` so recording a fresher
/// reading from a sensor already attributed to this survey replaces its old entry rather than
/// appending a duplicate.
class SurveySensorReadings {
  final Map<String, SensorData> _bySource = {};

  void record(SensorData reading) {
    _bySource[reading.source] = reading;
  }

  void clear() {
    _bySource.clear();
  }

  bool get isEmpty => _bySource.isEmpty;

  List<SensorData> toList() => _bySource.values.toList(growable: false);
}