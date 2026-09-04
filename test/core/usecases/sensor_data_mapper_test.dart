import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/sensor_data_mapper.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

void main() {
  group('SensorDataMapper', () {
    test('maps every configured parameter matched by the responding source', () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'temperature',
            name: 'Temperature',
            dataType: 'decimal',
            unit: 'C',
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'xiaomi', rawParameterCode: 'temperature'),
            ],
          ),
          SensorParameterDefinition(
            code: 'humidity',
            name: 'Humidity',
            dataType: 'decimal',
            unit: '%',
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'xiaomi', rawParameterCode: 'humidity'),
            ],
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(
              source: 'xiaomi', values: {'temperature': 21.5, 'humidity': 48}),
          setup);

      expect(values, hasLength(2));
      expect(values.map((v) => v.parameterCode),
          containsAll(['temperature', 'humidity']));
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
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'xiaomi', rawParameterCode: 'air_pressure'),
            ],
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

    test('ignores a parameter not sourced from the responding sensor type, even if the raw code matches',
        () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'temperature',
            name: 'Temperature',
            dataType: 'decimal',
            unit: 'C',
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'kestrel', rawParameterCode: 'temperature'),
            ],
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(source: 'xiaomi', values: {'temperature': 21.5}),
          setup);

      expect(values, isEmpty);
    });

    test('matches via a raw field name that differs from the parameter code',
        () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'ambient_temperature',
            name: 'Ambient Temperature',
            dataType: 'decimal',
            unit: 'C',
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'kestrel', rawParameterCode: 'temp'),
            ],
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(source: 'kestrel', values: {'temp': 19.0}),
          setup);

      expect(values, hasLength(1));
      expect(values.single.parameterCode, 'ambient_temperature');
      // `decimal`-typed parameters always format with exactly 2 decimals, even a value that is
      // itself a whole number -- this is what makes Ruuvi's hPa pressure (see
      // sensor_profile_resolver_test.dart) show up consistently everywhere it's read back.
      expect(values.single.value, '19.00');
    });

    test('formats a decimal parameter with exactly 2 decimals regardless of its raw precision',
        () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'pressure',
            name: 'Pressure',
            dataType: 'decimal',
            unit: 'hPa',
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'ruuvi', rawParameterCode: 'pressure'),
            ],
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(source: 'ruuvi', values: {'pressure': 1000.4}),
          setup);

      expect(values.single.value, '1000.40');
    });

    test('formats an integer parameter with no decimals', () {
      final setup = MobileSensorSetup(
        mode: MobileSensorSetup.configuredSensors,
        sensorTypes: const [],
        parameters: const [
          SensorParameterDefinition(
            code: 'movement',
            name: 'Movement',
            dataType: 'integer',
            unit: null,
            sources: [
              SensorParameterSource(
                  sensorTypeCode: 'ruuvi', rawParameterCode: 'movement'),
            ],
          ),
        ],
        assignments: const [],
      );

      final values = SensorDataMapper.fromResponse(
          const SensorReading(source: 'ruuvi', values: {'movement': 66}),
          setup);

      expect(values.single.value, '66');
    });
  });
}
