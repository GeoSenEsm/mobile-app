import 'dart:async';
import 'dart:io';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/ble_advertisement_decoder.dart';
import 'package:survey_frontend/core/usecases/gatt_profile_decoder.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_connection_factory.dart';
import 'package:survey_frontend/core/usecases/sensor_profile_resolver.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => Directory.systemTemp.path,
    );
  });

  test('seeded profiles decode Xiaomi and Kestrel equivalents', () {
    const resolver = SensorProfileResolver();

    final xiaomi = resolver.resolve('xiaomi', _setup('xiaomi')).profile!;
    final kestrel = resolver.resolve('kestrel', _setup('kestrel')).profile!;

    expect(xiaomi.sensorTypeCode, 'xiaomi');
    expect(xiaomi.reads.single.fields.map((field) => field.parameterCode),
        ['temperature', 'humidity']);
    expect(kestrel.reads, hasLength(2));
    expect(kestrel.discovery.exactName, 'D2 - {sensorId}');
  });

  test('Flower Care is a bounded write-delay-read profile', () {
    final profile = SeededGattProfiles.flowerCare;

    expect(profile.transport, 'gatt_sequence');
    expect(profile.actions.map((action) => action.type), ['write', 'delay']);
    expect(profile.actions.first.value, [0xa0, 0x1f]);
    expect(profile.actions.last.milliseconds, 500);
    expect(profile.reads.single.characteristicUuid,
        '00001a01-0000-1000-8000-00805f9b34fb');
    expect(
      const GattProfileDecoder().decode(profile, const [
        [215, 0, 0, 16, 39, 0, 0, 45, 244, 1]
      ]).values,
      {
        'temperature': 21.5,
        'light': 10000,
        'moisture': 45,
        'conductivity': 500,
      },
    );
  });

  test('Inkbird IBS-TH1 reads live temperature and humidity', () {
    final profile = SeededGattProfiles.inkbirdIbsTh1;

    expect(profile.discovery.exactName, 'sps');
    expect(profile.reads.single.characteristicUuid,
        '0000fff2-0000-1000-8000-00805f9b34fb');
    expect(
      const GattProfileDecoder().decode(profile, const [
        [177, 7, 193, 23, 0, 7, 98],
      ]).values,
      {'temperature': 19.69, 'humidity': 60.81},
    );
  });

  test('Door Sensor 2 is advertisement-driven and rejects a wrong key', () {
    final profile = SeededGattProfiles.doorSensor2;
    final packet = List<int>.filled(24, 0);
    packet[0] = 0x00;
    packet[1] = 0x48;
    packet[2] = 0x8b;
    packet[3] = 0x09;

    expect(profile.transport, 'ble_advertisement');
    expect(profile.advertisement!.decoderId, 'xiaomi_mibeacon_v4_v5');
    expect(
      () => const BleAdvertisementDecoder()
          .decode(profile, packet, List<int>.filled(16, 1)),
      throwsA(isA<AdvertisementPacketException>()),
    );
  });

  test('fails closed for unknown codes and absent coded adapters', () {
    const resolver = SensorProfileResolver();
    expect(
      () => resolver.resolve('unknown', _setup('unknown')),
      throwsA(isA<UnsupportedSensorException>()),
    );
    expect(
      () => resolver.resolve(
          'custom', _setup('custom', integrationMode: 'coded_adapter')),
      throwsA(isA<UnsupportedSensorException>()),
    );
  });

  test('resolves an explicitly registered coded adapter', () {
    final resolver = SensorProfileResolver(
      codedAdapters: CodedSensorAdapterRegistry({
        'custom': (_) async => const _FakeConnection(),
      }),
    );

    final resolved = resolver.resolve(
        'custom', _setup('custom', integrationMode: 'coded_adapter'));

    expect(resolved.codedAdapter, isNotNull);
    expect(resolved.profile, isNull);
  });

  test('matches exact, prefix, interpolated, and advertised service discovery',
      () {
    expect(
      SensorConnectionFactory.matchesDiscovery(
        const GattDiscovery(exactName: 'LYWSD03MMC'),
        platformName: '',
        advertisedName: 'LYWSD03MMC',
        advertisedServiceUuids: const {},
      ),
      isTrue,
    );
    expect(
      SensorConnectionFactory.matchesDiscovery(
        const GattDiscovery(
          namePrefix: 'D2 - ',
          advertisedServiceUuid: '12630000-cc25-497d-9854-9b6c02c77054',
        ),
        platformName: 'D2 - 42',
        advertisedName: '',
        advertisedServiceUuids: const {'12630000-CC25-497D-9854-9B6C02C77054'},
      ),
      isTrue,
    );
    expect(
      SensorConnectionFactory.matchesDiscovery(
        const GattDiscovery(exactName: 'D2 - {sensorId}'),
        platformName: 'D2 - 17',
        advertisedName: '',
        advertisedServiceUuids: const {},
        sensorId: '17',
      ),
      isTrue,
    );
  });

  test('uses the requested scan timeout and stops the scan', () async {
    const boxName = 'gatt_profile_timeout_test';
    await GetStorage.init(boxName);
    final storage = GetStorage(boxName);
    await storage.erase();
    await storage.write('selectedSensor', 'xiaomi');
    final scanner = _NoResultScanner();
    final factory = SensorConnectionFactory(storage, scanner: scanner);
    final stopwatch = Stopwatch()..start();

    await expectLater(
      factory.getSensorConnection(const Duration(milliseconds: 60)),
      throwsA(isA<SensorNotFoundException>()),
    );

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(45));
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    expect(scanner.stopped, isTrue);
  });
}

MobileSensorSetup _setup(String code,
        {String integrationMode = 'profile'}) =>
    MobileSensorSetup(
      mode: MobileSensorSetup.configuredSensors,
      sensorTypes: [
        SensorTypeSetting(
          sensorTypeCode: code,
          sensorTypeName: code,
          enabled: true,
          connectionTimeoutSeconds: 60,
          displayOrder: 0,
          integrationMode: integrationMode,
        ),
      ],
      parameters: const [],
      assignments: const [],
    );

class _FakeConnection implements SensorConnection {
  const _FakeConnection();

  @override
  Future<void> dispose() async {}

  @override
  Future<SensorReading> getSensorData() async =>
      const SensorReading(source: 'custom', values: {});
}

class _NoResultScanner implements BluetoothScanGateway {
  final StreamController<List<ScanResult>> _results =
      StreamController<List<ScanResult>>.broadcast();
  bool stopped = false;

  @override
  Future<BluetoothAdapterState> adapterState() async =>
      BluetoothAdapterState.on;

  @override
  Stream<List<ScanResult>> get scanResults => _results.stream;

  @override
  Future<void> startScan(Duration timeout) async {}

  @override
  Future<void> stopScan() async {
    stopped = true;
    await _results.close();
  }
}
