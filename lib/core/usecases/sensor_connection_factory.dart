import 'dart:async';
import 'dart:convert';

import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/ble_advertisement_decoder.dart';
import 'package:survey_frontend/core/usecases/sensor_bind_key_store.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/core/usecases/sensor_profile_resolver.dart';
import 'package:survey_frontend/data/models/sensor_kind.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

class SensorConnectionFactory {
  final GetStorage _storage;
  final SensorProfileResolver _resolver;
  final BluetoothScanGateway _scanner;
  final SensorBindKeyStore _bindKeyStore;
  final BleAdvertisementDecoder _advertisementDecoder;

  SensorConnectionFactory(
    this._storage, {
    SensorProfileResolver resolver = const SensorProfileResolver(),
    BluetoothScanGateway scanner = const FlutterBlueScanGateway(),
    SensorBindKeyStore bindKeyStore = const SensorBindKeyStore(),
    BleAdvertisementDecoder advertisementDecoder =
        const BleAdvertisementDecoder(),
  })  : _resolver = resolver,
        _scanner = scanner,
        _bindKeyStore = bindKeyStore,
        _advertisementDecoder = advertisementDecoder;

  Future<SensorConnection> getSensorConnection(
      Duration scanningDuration) async {
    final sensorTypeCode = _storage.read<String>('selectedSensor');
    if ((await _scanner.adapterState()) != BluetoothAdapterState.on) {
      throw BluetoothTurnedOffException();
    }
    if (sensorTypeCode == null || !SensorKind.usesBluetooth(sensorTypeCode)) {
      throw SensorNotSpecifiedException();
    }

    final setup = _readSetupOrLegacy(sensorTypeCode);
    final integration = _resolver.resolve(sensorTypeCode, setup);
    final profile = integration.profile;
    if (integration.codedAdapter != null) {
      return integration.codedAdapter!(scanningDuration);
    }
    if (profile!.transport == 'ble_advertisement') {
      return AdvertisementSensorConnection(
          await _readAdvertisement(profile, scanningDuration));
    }
    final device = await _findDevice(profile, scanningDuration);
    await device.connect();
    return GattProfileSensorConnection(device, profile);
  }

  Future<SensorReading> _readAdvertisement(
      GattProfile profile, Duration requestedTimeout) async {
    final definition = profile.advertisement!;
    final sensorId = _storage.read<Object>('selectedSensorId')?.toString();
    final bindKey = await _bindKeyStore.read(profile.sensorTypeCode, sensorId);
    if (bindKey == null) {
      throw const SensorBindKeyUnavailableException();
    }
    final configuredTimeout =
        Duration(milliseconds: definition.timeoutMilliseconds);
    final timeout = requestedTimeout < configuredTimeout
        ? requestedTimeout
        : configuredTimeout;
    final serviceUuidValue = definition.serviceUuid;
    final serviceUuid =
        serviceUuidValue == null ? null : Guid(serviceUuidValue);
    final completer = Completer<SensorReading>();
    var packetsSeen = 0;
    late StreamSubscription<List<ScanResult>> subscription;
    Timer? timer;
    subscription = _scanner.scanResults.listen((results) {
      for (final result in results) {
        final payload = definition.dataSource == 'manufacturer_data'
            ? result.advertisementData.manufacturerData[definition.manufacturerId]
            : result.advertisementData.serviceData[serviceUuid];
        if (payload == null || completer.isCompleted) continue;
        packetsSeen++;
        try {
          completer.complete(
              _advertisementDecoder.decode(profile, payload, bindKey));
        } on AdvertisementPacketException {
          if (packetsSeen >= definition.maxPackets) {
            completer.completeError(const AdvertisementPacketException(
                'No valid advertisement within maxPackets'));
          }
        }
      }
    });
    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(
              const AdvertisementPacketException('Advertisement timed out'));
        }
      });
      await _scanner.startScan(timeout);
      return await completer.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      await _scanner.stopScan();
    }
  }

  Future<BluetoothDevice> _findDevice(
      GattProfile? profile, Duration timeout) async {
    if (profile == null) {
      throw const SensorDiscoveryUnavailableException();
    }
    final completer = Completer<BluetoothDevice>();
    final sensorId = _storage.read<Object>('selectedSensorId')?.toString();
    final sensorMac = _storage.read<String>('selectedSensorMac') ??
        _storage.read<String>('xiaomiMac');
    late StreamSubscription<List<ScanResult>> subscription;
    Timer? timer;
    subscription = _scanner.scanResults.listen((results) {
      for (final result in results) {
        final isAssignedDevice = sensorMac != null &&
            result.device.remoteId.str.toLowerCase() == sensorMac.toLowerCase();
        final matchesProfile = sensorMac == null &&
            matchesDiscovery(
              profile.discovery,
              platformName: result.device.platformName,
              advertisedName: result.device.advName,
              advertisedServiceUuids: result.advertisementData.serviceUuids
                  .map((uuid) => uuid.str)
                  .toSet(),
              sensorId: sensorId,
            );
        if ((isAssignedDevice || matchesProfile) && !completer.isCompleted) {
          completer.complete(result.device);
          break;
        }
      }
    });
    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(SensorNotFoundException());
        }
      });
      await _scanner.startScan(timeout);
      return await completer.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      await _scanner.stopScan();
    }
  }

  MobileSensorSetup _readSetupOrLegacy(String sensorTypeCode) {
    final raw = _storage.read<String>(MobileSensorSetup.storageKey);
    if (raw != null) {
      return MobileSensorSetup.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    }
    if (!SeededGattProfiles.all
        .any((profile) => profile.sensorTypeCode == sensorTypeCode)) {
      throw UnsupportedSensorException(sensorTypeCode);
    }
    return MobileSensorSetup(
      mode: MobileSensorSetup.configuredSensors,
      sensorTypes: [
        SensorTypeSetting(
          sensorTypeCode: sensorTypeCode,
          sensorTypeName: sensorTypeCode,
          enabled: true,
          connectionTimeoutSeconds: 30,
          displayOrder: 0,
        ),
      ],
      parameters: const [],
      assignments: const [],
    );
  }

  static bool matchesDiscovery(
    GattDiscovery discovery, {
    required String platformName,
    required String advertisedName,
    required Set<String> advertisedServiceUuids,
    String? sensorId,
  }) {
    final exactName =
        discovery.exactName?.replaceAll('{sensorId}', sensorId ?? '');
    final names = {platformName, advertisedName};
    final nameMatches = exactName != null
        ? names.contains(exactName)
        : discovery.namePrefix != null
            ? names.any((name) => name.startsWith(discovery.namePrefix!))
            : true;
    final requiredService = discovery.advertisedServiceUuid;
    return nameMatches &&
        (requiredService == null ||
            advertisedServiceUuids
                .map((uuid) => uuid.toLowerCase())
                .contains(requiredService));
  }
}

abstract class BluetoothScanGateway {
  Stream<List<ScanResult>> get scanResults;
  Future<BluetoothAdapterState> adapterState();
  Future<void> startScan(Duration timeout);
  Future<void> stopScan();
}

class FlutterBlueScanGateway implements BluetoothScanGateway {
  const FlutterBlueScanGateway();

  @override
  Stream<List<ScanResult>> get scanResults => FlutterBluePlus.scanResults;

  @override
  Future<BluetoothAdapterState> adapterState() =>
      FlutterBluePlus.adapterState.first;

  @override
  Future<void> startScan(Duration timeout) =>
      FlutterBluePlus.startScan(timeout: timeout);

  @override
  Future<void> stopScan() => FlutterBluePlus.stopScan();
}

class GetSensorConnectionException implements Exception {}

class SensorNotSpecifiedException implements GetSensorConnectionException {}

class SensorNotFoundException implements GetSensorConnectionException {}

class BluetoothTurnedOffException implements GetSensorConnectionException {}

class SensorDiscoveryUnavailableException
    implements GetSensorConnectionException {
  const SensorDiscoveryUnavailableException();
}

class SensorBindKeyUnavailableException
    implements GetSensorConnectionException {
  const SensorBindKeyUnavailableException();

  @override
  String toString() => 'Sensor bind key is unavailable';
}
