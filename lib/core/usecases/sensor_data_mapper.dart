import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

class SensorDataMapper {
  static List<SensorDataValue> fromResponse(
      SensorReading response, MobileSensorSetup? setup) {
    final rawValues = response.values;
    final parameters = setup?.parameters ?? const [];

    if (parameters.isEmpty) {
      return rawValues.entries
          .map((entry) => SensorDataValue(
              parameterCode: entry.key, value: entry.value.toString()))
          .toList();
    }

    return parameters
        .where((parameter) =>
            parameter.active && rawValues.containsKey(parameter.code))
        .map((parameter) => SensorDataValue(
            parameterCode: parameter.code,
            value: rawValues[parameter.code]?.toString() ?? ''))
        .toList();
  }
}
