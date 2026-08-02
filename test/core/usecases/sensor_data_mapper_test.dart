import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/sensor_data_mapper.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

void main() {
  group('SensorDataMapper', () {
    test('maps only active configured parameters returned by the sensor', () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'temperature',
            name: 'Temperature',
            dataType: 'decimal',
            unit: 'C',
            required: true,
            active: true,
          ),
          SensorParameterDefinition(
            code: 'humidity',
            name: 'Humidity',
            dataType: 'decimal',
            unit: '%',
            required: true,
            active: false,
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(
              source: 'xiaomi', values: {'temperature': 21.5, 'humidity': 48}),
          setup);

      expect(values, hasLength(1));
      expect(values.single.parameterCode, 'temperature');
      expect(values.single.value, '21.5');
    });

    test('returns no values when configured parameters do not match response',
        () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'air_pressure',
            name: 'Air pressure',
            dataType: 'decimal',
            unit: 'hPa',
            required: true,
            active: true,
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(
              source: 'xiaomi', values: {'temperature': 21.5, 'humidity': 48}),
          setup);

      expect(values, isEmpty);
    });
  });
}
