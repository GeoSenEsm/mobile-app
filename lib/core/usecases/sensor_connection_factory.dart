import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  /// Guards the scan → connect → in-use lifetime of a connection to one sensor *type*, not the
  /// whole app: the background task, the manual sensor screen, and the survey-end fallback all
  /// resolve this same singleton, so without this lock any two of them could independently
  /// scan/connect to the *same* physical sensor at once and each submit their own copy of the
  /// reading. It's keyed by sensor type rather than a single flag so unrelated sensor types can
  /// still be connected to concurrently. Released when the returned [SensorConnection] is
  /// disposed, not when this method returns.
  static final Set<String> _sensorTypesInProgress = {};

  Future<SensorConnection> getSensorConnection(
    Duration scanningDuration, {
    required String sensorTypeCode,
    String? sensorId,
    String? sensorMac,
  }) async {
    if (!SensorKind.usesBluetooth(sensorTypeCode)) {
      throw SensorNotSpecifiedException();
    }
    if (_sensorTypesInProgress.contains(sensorTypeCode)) {
      throw const SensorConnectionBusyException();
    }
    _sensorTypesInProgress.add(sensorTypeCode);
    try {
      final connection = await _acquireSensorConnection(
          scanningDuration, sensorTypeCode, sensorId, sensorMac);
      return _GuardedSensorConnection(
          connection, () => _sensorTypesInProgress.remove(sensorTypeCode));
    } catch (_) {
      _sensorTypesInProgress.remove(sensorTypeCode);
      rethrow;
    }
  }

  Future<SensorConnection> _acquireSensorConnection(Duration scanningDuration,
      String sensorTypeCode, String? sensorId, String? sensorMac) async {
    if ((await _scanner.adapterState()) != BluetoothAdapterState.on) {
      throw BluetoothTurnedOffException();
    }

    final setup = _readSetupOrLegacy(sensorTypeCode);
    final integration = _resolver.resolve(sensorTypeCode, setup);
    final profile = integration.profile;
    if (integration.codedAdapter != null) {
      return integration.codedAdapter!(scanningDuration);
    }
    if (profile!.transport == 'ble_advertisement') {
      return AdvertisementSensorConnection(await _readAdvertisement(
          profile, scanningDuration, sensorId, sensorMac));
    }
    final device =
        await _findDevice(profile, scanningDuration, sensorId, sensorMac);
    await device.connect();
    return GattProfileSensorConnection(device, profile);
  }

  Future<SensorReading> _readAdvertisement(GattProfile profile,
      Duration requestedTimeout, String? sensorId, String? sensorMac) async {
    final definition = profile.advertisement!;
    final bindKey = await _bindKeyStore.read(profile.sensorTypeCode, sensorId);
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
        if (sensorMac != null &&
            result.device.remoteId.str.toLowerCase() != sensorMac.toLowerCase()) {
          continue;
        }
        final payload = definition.dataSource == 'manufacturer_data'
            ? result.advertisementData.manufacturerData[definition.manufacturerId]
            : result.advertisementData.serviceData[serviceUuid];
        debugPrint('[advertisement:${profile.sensorTypeCode}] '
            'mac=${result.device.remoteId.str} '
            'serviceData=${result.advertisementData.serviceData.keys} '
            'manufacturerData=${result.advertisementData.manufacturerData.keys} '
            'wantServiceUuid=$serviceUuid payloadFound=${payload != null}');
        if (payload == null || completer.isCompleted) continue;
        packetsSeen++;
        try {
          completer.complete(
              _advertisementDecoder.decode(profile, payload, bindKey));
        } on AdvertisementPacketException catch (e) {
          debugPrint('[advertisement:${profile.sensorTypeCode}] '
              'decode rejected payload=$payload bindKeySet=${bindKey != null}: ${e.message}');
          if (packetsSeen >= definition.maxPackets) {
            completer.completeError(const AdvertisementPacketException(
                'No valid advertisement within maxPackets'));
          }
        }
      }
    });
    await _acquireSharedScan();
    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(
              const AdvertisementPacketException('Advertisement timed out'));
        }
      });
      return await completer.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      await _releaseSharedScan();
    }
  }

  Future<BluetoothDevice> _findDevice(GattProfile? profile, Duration timeout,
      String? sensorId, String? sensorMac) async {
    if (profile == null) {
      throw const SensorDiscoveryUnavailableException();
    }
    final completer = Completer<BluetoothDevice>();
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
        if (result.device.platformName.isNotEmpty ||
            result.device.advName.isNotEmpty) {
          debugPrint('[discovery:${profile.sensorTypeCode}] '
              'mac=${result.device.remoteId.str} '
              'platformName="${result.device.platformName}" '
              'advName="${result.device.advName}" '
              'services=${result.advertisementData.serviceUuids} '
              'wantMac=$sensorMac wantExactName=${profile.discovery.exactName} '
              'wantNamePrefix=${profile.discovery.namePrefix} '
              'wantServiceUuid=${profile.discovery.advertisedServiceUuid} '
              'matched=${isAssignedDevice || matchesProfile}');
        }
        if ((isAssignedDevice || matchesProfile) && !completer.isCompleted) {
          completer.complete(result.device);
          break;
        }
      }
    });
    await _acquireSharedScan();
    try {
      timer = Timer(timeout, () {
        if (!completer.isCompleted) {
          completer.completeError(SensorNotFoundException());
        }
      });
      return await completer.future;
    } finally {
      timer?.cancel();
      await subscription.cancel();
      await _releaseSharedScan();
    }
  }

  /// [BluetoothScanGateway.startScan]/[stopScan] control a single BLE radio scan shared by the
  /// whole app — there is no way to run two independent scan sessions with different durations
  /// at once. When more than one sensor-type discovery is in flight concurrently, they share one
  /// long-lived scan instead: the first caller starts it (with a ceiling far longer than any real
  /// per-sensor timeout, since each caller's own [Timer] above already bounds its own wait), and
  /// it only stops once every concurrent caller has finished with it.
  static int _sharedScanClients = 0;
  static const Duration _sharedScanCeiling = Duration(minutes: 10);

  Future<void> _acquireSharedScan() async {
    _sharedScanClients++;
    if (_sharedScanClients == 1) {
      await _scanner.startScan(_sharedScanCeiling);
    }
  }

  Future<void> _releaseSharedScan() async {
    _sharedScanClients--;
    if (_sharedScanClients <= 0) {
      _sharedScanClients = 0;
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
    // Device-advertised names carry no meaningful case distinction, and firmware across
    // batches/manufacturers is inconsistent about it (e.g. "Flower care" vs "Flower Care") — match
    // case-insensitively so a harmless casing difference doesn't look like a missing sensor.
    final exactName = discovery.exactName
        ?.replaceAll('{sensorId}', sensorId ?? '')
        .toLowerCase();
    final namePrefix = discovery.namePrefix?.toLowerCase();
    final names = {platformName.toLowerCase(), advertisedName.toLowerCase()};
    final nameMatches = exactName != null
        ? names.contains(exactName)
        : namePrefix != null
            ? names.any((name) => name.startsWith(namePrefix))
            : true;
    // [advertisedServiceUuids] entries are already Guid.str — the shortest representation the
    // platform reports (a base 16-bit UUID like "fe95" comes back short, not as its full 128-bit
    // string). A config value entered as the full 128-bit form for the same base UUID would never
    // equal that, so normalize it through Guid the same way before comparing.
    final requiredService = discovery.advertisedServiceUuid;
    final normalizedRequiredService =
        requiredService == null ? null : Guid(requiredService).str.toLowerCase();
    return nameMatches &&
        (normalizedRequiredService == null ||
            advertisedServiceUuids
                .map((uuid) => uuid.toLowerCase())
                .contains(normalizedRequiredService));
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

/// Wraps a [SensorConnection] so this sensor type's lock is released exactly
/// once, whenever the caller is actually done with it, rather than as soon
/// as it is acquired.
class _GuardedSensorConnection implements SensorConnection {
  final SensorConnection _inner;
  final void Function() _releaseLock;
  bool _released = false;

  _GuardedSensorConnection(this._inner, this._releaseLock);

  @override
  Future<SensorReading> getSensorData() => _inner.getSensorData();

  @override
  Future<void> dispose() async {
    try {
      await _inner.dispose();
    } finally {
      if (!_released) {
        _released = true;
        _releaseLock();
      }
    }
  }
}

class GetSensorConnectionException implements Exception {}

class SensorConnectionBusyException implements GetSensorConnectionException {
  const SensorConnectionBusyException();

  @override
  String toString() =>
      'Another sensor connection attempt is already in progress';
}

class SensorNotSpecifiedException implements GetSensorConnectionException {}

class SensorNotFoundException implements GetSensorConnectionException {}

class BluetoothTurnedOffException implements GetSensorConnectionException {}

class SensorDiscoveryUnavailableException
    implements GetSensorConnectionException {
  const SensorDiscoveryUnavailableException();
}
