import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/domain/models/sensor_data.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

class SensorDataMapper {
  /// Matches a raw BLE/native reading to admin-configured parameters via each parameter's
  /// [SensorParameterSource] for [response.source] — a raw field name can legitimately differ
  /// from the parameter's own `code` (e.g. a custom sensor type wired to an existing column), so
  /// this no longer assumes they're the same string.
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

    final values = <SensorDataValue>[];
    for (final parameter in parameters) {
      final source = parameter.sourceFor(response.source);
      if (source == null || !rawValues.containsKey(source.rawParameterCode)) {
        continue;
      }
      values.add(SensorDataValue(
          parameterCode: parameter.code,
          value: _formatValue(
              rawValues[source.rawParameterCode]!, parameter.dataType)));
    }
    return values;
  }

  /// Formats an automatically-read value according to its parameter's declared `dataType`,
  /// rather than the raw Dart runtime type (`int` vs `double`) the decoder happened to produce.
  /// Without this, a `decimal` parameter whose value is currently a whole number (e.g. Ruuvi's
  /// hPa pressure reading) would print with zero or one decimal instead of a consistent two.
  static String _formatValue(num value, String dataType) {
    switch (dataType) {
      case 'decimal':
        return value.toStringAsFixed(2);
      case 'integer':
        return value.round().toString();
      default:
        return value.toString();
    }
  }
}
