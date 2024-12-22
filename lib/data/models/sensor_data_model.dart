class SensorDataModel {
  final DateTime dateTime;
  final double temperature;
  final double humidity;
  final bool sentToServer;

  SensorDataModel(
      {required this.dateTime,
      required this.temperature,
      required this.humidity,
      required this.sentToServer});
}
