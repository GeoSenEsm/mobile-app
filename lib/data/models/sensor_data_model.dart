import 'package:survey_frontend/domain/models/sensor_data.dart';

class SensorDataModel {
  final DateTime dateTime;
  final String source;
  final List<SensorDataValue> values;
  final bool sentToServer;

  SensorDataModel(
      {required this.dateTime,
      required this.source,
      required this.values,
      required this.sentToServer});
}
