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

  test('seeded profiles resolve Xiaomi and Kestrel equivalents', () {
    const resolver = SensorProfileResolver();

    final xiaomi = resolver.resolve('xiaomi', _setup('xiaomi')).profile!;
    final kestrel = resolver.resolve('kestrel', _setup('kestrel')).profile!;

    expect(xiaomi.sensorTypeCode, 'xiaomi');
    expect(xiaomi.transport, 'gatt_sequence');
    expect(xiaomi.discovery.exactName, 'LYWSD03MMC');
    expect(xiaomi.reads.single.characteristicUuid,
        'ebe0ccc1-7a0a-4b0c-8a1a-6ff2997da3a6');
    expect(kestrel.reads, hasLength(2));
    expect(kestrel.discovery.exactName, 'D2 - {sensorId}');
  });

  test('Xiaomi LYWSD03MMC reads temperature and humidity from its own GATT service',
      () {
    final profile = SeededGattProfiles.xiaomi;
    // Real units broadcast encrypted MiBeacon which this app cannot decode, so this profile uses
    // GATT transport instead: temperature=2150 (*0.01=21.5), humidity=45, matching the proven
    // v.2.0.1 byte layout.
    final packet = [0x66, 0x08, 0x2D];

    final reading = const GattProfileDecoder().decode(profile, [packet]);

    expect(reading.values, {
      'temperature': 21.5,
      'humidity': 45,
    });
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

  test('RuuviTag decodes its fixed-offset Data Format 5 (RAWv2) payload', () {
    final profile = SeededGattProfiles.ruuvi;
    // Official test vector from ruuvi/ruuvi-sensor-protocols' Data Format 5 spec: manufacturer
    // data payload only (no company-id bytes), matching what flutter_blue_plus hands the decoder
    // via AdvertisementData.manufacturerData[0x0499].
    final payload = [
      0x05, 0x12, 0xFC, 0x53, 0x94, 0xC3, 0x7C, 0x00, //
      0x04, 0xFF, 0xFC, 0x04, 0x0C, 0xAC, 0x36, 0x42, //
      0x00, 0xCD, 0xCB, 0xB8, 0x33, 0x4C, 0x88, 0x4F, //
    ];

    expect(profile.transport, 'ble_advertisement');
    expect(profile.advertisement!.decoderId, 'ruuvi_data_format_5');
    expect(profile.advertisement!.usesFixedOffsetFields, isTrue);
    final reading = const BleAdvertisementDecoder().decode(profile, payload);

    expect(reading.values, {
      'temperature': 24.3,
      'humidity': 53.49,
      'pressure': 1000.44,
      'movement': 66,
    });
  });

  test('RuuviTag decoder rejects a payload too short for its declared fields', () {
    final profile = SeededGattProfiles.ruuvi;
    final tooShort = List<int>.filled(10, 0);

    expect(
      () => const BleAdvertisementDecoder().decode(profile, tooShort),
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
    final scanner = _NoResultScanner();
    final factory = SensorConnectionFactory(storage, scanner: scanner);
    final stopwatch = Stopwatch()..start();

    await expectLater(
      factory.getSensorConnection(const Duration(milliseconds: 60),
          sensorTypeCode: 'kestrel'),
      throwsA(isA<SensorNotFoundException>()),
    );

    stopwatch.stop();
    expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(45));
    expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    expect(scanner.stopped, isTrue);
  });

  test(
      'advertisement transport picks the assigned MAC out of several matching devices',
      () async {
    const boxName = 'gatt_profile_advertisement_mac_test';
    await GetStorage.init(boxName);
    final storage = GetStorage(boxName);
    await storage.erase();

    final scanner = _FixedResultsScanner([
      _ruuviScanResult('AA:AA:AA:AA:AA:AA', movement: 10),
      _ruuviScanResult('BB:BB:BB:BB:BB:BB', movement: 20),
    ]);
    final factory = SensorConnectionFactory(storage, scanner: scanner);

    final connection = await factory.getSensorConnection(
        const Duration(seconds: 1),
        sensorTypeCode: 'ruuvi',
        sensorMac: 'BB:BB:BB:BB:BB:BB');
    final reading = await connection.getSensorData();

    expect(reading.values['movement'], 20);
  });
}

const _ruuviManufacturerId = 0x0499;

/// Builds a RuuviTag Data Format 5 (RAWv2) manufacturer-data advertisement, with a caller-chosen
/// `movement` value so tests can tell which of several matching devices' data actually made it
/// through.
ScanResult _ruuviScanResult(String mac, {required int movement}) {
  final payload = <int>[
    0x05, 0x12, 0xFC, 0x53, 0x94, 0xC3, 0x7C, 0x00, //
    0x04, 0xFF, 0xFC, 0x04, 0x0C, 0xAC, 0x36, movement, //
    0x00, 0xCD, 0xCB, 0xB8, 0x33, 0x4C, 0x88, 0x4F, //
  ];
  return ScanResult(
    device: BluetoothDevice.fromId(mac),
    advertisementData: AdvertisementData(
      advName: '',
      txPowerLevel: null,
      appearance: null,
      connectable: true,
      manufacturerData: {_ruuviManufacturerId: payload},
      serviceData: const {},
      serviceUuids: const [],
    ),
    rssi: -60,
    timeStamp: DateTime.fromMillisecondsSinceEpoch(0),
  );
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

class _FixedResultsScanner implements BluetoothScanGateway {
  final List<ScanResult> results;
  final StreamController<List<ScanResult>> _controller =
      StreamController<List<ScanResult>>.broadcast();

  _FixedResultsScanner(this.results);

  @override
  Future<BluetoothAdapterState> adapterState() async =>
      BluetoothAdapterState.on;

  @override
  Stream<List<ScanResult>> get scanResults => _controller.stream;

  @override
  Future<void> startScan(Duration timeout) async {
    _controller.add(results);
  }

  @override
  Future<void> stopScan() async {
    await _controller.close();
  }
}
