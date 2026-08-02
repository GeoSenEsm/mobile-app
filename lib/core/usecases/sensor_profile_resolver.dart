import 'package:survey_frontend/core/usecases/gatt_profile_decoder.dart';
import 'package:survey_frontend/core/usecases/sensor_connection.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';
import 'package:survey_frontend/domain/models/survey_settings.dart';

typedef CodedSensorAdapterFactory = Future<SensorConnection> Function(
    Duration connectionTimeout);

class CodedSensorAdapterRegistry {
  final Map<String, CodedSensorAdapterFactory> _factories;

  const CodedSensorAdapterRegistry(
      [Map<String, CodedSensorAdapterFactory> factories = const {}])
      : _factories = factories;

  CodedSensorAdapterFactory? find(String sensorTypeCode) =>
      _factories[sensorTypeCode];
}

class SensorProfileResolver {
  static const String gattProfileMode = 'profile';
  static const Set<String> codedAdapterModes = {'native', 'coded_adapter'};

  final CodedSensorAdapterRegistry codedAdapters;
  final GattProfileDecoder decoder;

  const SensorProfileResolver({
    this.codedAdapters = const CodedSensorAdapterRegistry(),
    this.decoder = const GattProfileDecoder(),
  });

  ResolvedSensorIntegration resolve(
      String sensorTypeCode, MobileSensorSetup setup) {
    final setting = setup.sensorTypes
        .where((candidate) =>
            candidate.enabled && candidate.sensorTypeCode == sensorTypeCode)
        .firstOrNull;
    if (setting == null) {
      throw UnsupportedSensorException(sensorTypeCode);
    }

    if (codedAdapterModes.contains(setting.integrationMode)) {
      final adapter = codedAdapters.find(sensorTypeCode);
      if (adapter == null) {
        throw UnsupportedSensorException(sensorTypeCode);
      }
      return ResolvedSensorIntegration.coded(adapter);
    }
    if (setting.integrationMode != gattProfileMode) {
      throw UnsupportedSensorException(sensorTypeCode);
    }

    final candidates = [
      ...setup.gattProfiles,
      ...SeededGattProfiles.all.where((profile) => !setup.gattProfiles.any(
          (configured) => configured.sensorTypeCode == profile.sensorTypeCode)),
    ].where((profile) => profile.sensorTypeCode == sensorTypeCode).toList();
    if (candidates.isEmpty) {
      throw UnsupportedSensorException(sensorTypeCode);
    }
    candidates.sort((a, b) => b.revision.compareTo(a.revision));
    final profile = candidates.first;
    if (profile.transport == 'gatt_sequence') {
      decoder.validateGoldenVectors(profile);
    }
    return ResolvedSensorIntegration.gatt(profile);
  }
}

class ResolvedSensorIntegration {
  final GattProfile? profile;
  final CodedSensorAdapterFactory? codedAdapter;

  const ResolvedSensorIntegration._({this.profile, this.codedAdapter});

  const ResolvedSensorIntegration.gatt(GattProfile profile)
      : this._(profile: profile);

  const ResolvedSensorIntegration.coded(CodedSensorAdapterFactory codedAdapter)
      : this._(codedAdapter: codedAdapter);
}

class SeededGattProfiles {
  static final GattProfile xiaomi = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'xiaomi',
    'minEngineVersion': 1,
    'discovery': {'exactName': 'LYWSD03MMC'},
    'reads': [
      {
        'serviceUuid': 'ebe0ccb0-7a0a-4b0c-8a1a-6ff2997da3a6',
        'characteristicUuid': 'ebe0ccc1-7a0a-4b0c-8a1a-6ff2997da3a6',
        'assertions': [],
        'fields': [
          {
            'parameterCode': 'temperature',
            'type': 'uint16',
            'endian': 'little',
            'byteOffset': 0,
            'scale': 0.01,
          },
          {
            'parameterCode': 'humidity',
            'type': 'uint8',
            'endian': 'little',
            'byteOffset': 2,
          },
        ],
      },
    ],
    'goldenVectors': [
      {
        'packets': [
          [102, 8, 48]
        ],
        'expectedValues': {'temperature': 21.5, 'humidity': 48},
      },
    ],
  });

  static final GattProfile kestrel = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'kestrel',
    'minEngineVersion': 1,
    'discovery': {'exactName': 'D2 - {sensorId}'},
    'reads': [
      {
        'serviceUuid': '12630000-cc25-497d-9854-9b6c02c77054',
        'characteristicUuid': '12630001-cc25-497d-9854-9b6c02c77054',
        'assertions': [
          {
            'byteOffset': 0,
            'equals': [7],
          },
        ],
        'fields': [
          {
            'parameterCode': 'temperature',
            'type': 'uint16',
            'endian': 'little',
            'byteOffset': 1,
            'scale': 0.01,
          },
        ],
      },
      {
        'serviceUuid': '12630000-cc25-497d-9854-9b6c02c77054',
        'characteristicUuid': '12630002-cc25-497d-9854-9b6c02c77054',
        'assertions': [
          {
            'byteOffset': 0,
            'equals': [7],
          },
        ],
        'fields': [
          {
            'parameterCode': 'humidity',
            'type': 'uint16',
            'endian': 'little',
            'byteOffset': 1,
            'scale': 0.01,
          },
        ],
      },
    ],
    'goldenVectors': [
      {
        'packets': [
          [7, 102, 8],
          [7, 192, 18],
        ],
        'expectedValues': {'temperature': 21.5, 'humidity': 48},
      },
    ],
  });

  static final GattProfile inkbirdIbsTh1 = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'inkbird_ibs_th1',
    'minEngineVersion': 1,
    'transport': 'gatt_sequence',
    'discovery': {
      'exactName': 'sps',
      'advertisedServiceUuid': '0000fff0-0000-1000-8000-00805f9b34fb',
    },
    'reads': [
      {
        'serviceUuid': '0000fff0-0000-1000-8000-00805f9b34fb',
        'characteristicUuid': '0000fff2-0000-1000-8000-00805f9b34fb',
        'acquisition': {
          'mode': 'read',
          'timeoutMilliseconds': 10000,
          'maxPackets': 1,
        },
        'frame': {'exactLength': 7},
        'assertions': [],
        'fields': [
          {
            'parameterCode': 'temperature',
            'type': 'int16',
            'endian': 'little',
            'byteOffset': 0,
            'scale': 0.01,
            'minimum': -40,
            'maximum': 125,
          },
          {
            'parameterCode': 'humidity',
            'type': 'uint16',
            'endian': 'little',
            'byteOffset': 2,
            'scale': 0.01,
            'minimum': 0,
            'maximum': 100,
          },
        ],
      },
    ],
    'goldenVectors': [
      {
        'packets': [
          [177, 7, 193, 23, 0, 7, 98],
        ],
        'expectedValues': {'temperature': 19.69, 'humidity': 60.81},
      },
    ],
  });

  static final GattProfile pc60fw = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'pc_60fw',
    'minEngineVersion': 1,
    'transport': 'gatt_sequence',
    'discovery': {'namePrefix': 'PC-60'},
    'reads': [
      {
        'serviceUuid': '6e400001-b5a3-f393-e0a9-e50e24dcca9e',
        'characteristicUuid': '6e400003-b5a3-f393-e0a9-e50e24dcca9e',
        'acquisition': {
          'mode': 'notification',
          'timeoutMilliseconds': 10000,
          'maxPackets': 30,
        },
        'frame': {
          'exactLength': 12,
          'prefix': [170, 85, 15, 8, 1],
          'checksum': 'crc8_maxim',
        },
        'assertions': [],
        'fields': [
          {
            'parameterCode': 'spo2',
            'type': 'uint8',
            'endian': 'little',
            'byteOffset': 5,
            'minimum': 0,
            'maximum': 100,
          },
          {
            'parameterCode': 'pulse_rate',
            'type': 'uint8',
            'endian': 'little',
            'byteOffset': 6,
          },
          {
            'parameterCode': 'perfusion_index',
            'type': 'uint8',
            'endian': 'little',
            'byteOffset': 8,
            'scale': 0.1,
          },
        ],
      },
    ],
  });

  static final GattProfile plxContinuous = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'bluetooth_sig_plx',
    'minEngineVersion': 1,
    'transport': 'gatt_sequence',
    'discovery': {'advertisedServiceUuid': '1822'},
    'reads': [
      {
        'serviceUuid': '1822',
        'characteristicUuid': '2a5f',
        'acquisition': {
          'mode': 'notification',
          'timeoutMilliseconds': 10000,
          'maxPackets': 30,
        },
        'frame': {'minimumLength': 5},
        'assertions': [],
        'fields': [
          {
            'parameterCode': 'spo2',
            'type': 'sfloat16',
            'endian': 'little',
            'byteOffset': 1,
            'minimum': 0,
            'maximum': 100,
          },
          {
            'parameterCode': 'pulse_rate',
            'type': 'sfloat16',
            'endian': 'little',
            'byteOffset': 3,
            'minimum': 0,
          },
        ],
      },
    ],
  });

  static final GattProfile flowerCare = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'flower_care',
    'minEngineVersion': 1,
    'transport': 'gatt_sequence',
    'discovery': {'exactName': 'Flower care'},
    'actions': [
      {
        'type': 'write',
        'serviceUuid': '00001204-0000-1000-8000-00805f9b34fb',
        'characteristicUuid': '00001a00-0000-1000-8000-00805f9b34fb',
        'value': [160, 31],
      },
      {'type': 'delay', 'milliseconds': 500},
    ],
    'reads': [
      {
        'serviceUuid': '00001204-0000-1000-8000-00805f9b34fb',
        'characteristicUuid': '00001a01-0000-1000-8000-00805f9b34fb',
        'frame': {'minimumLength': 10},
        'assertions': [],
        'fields': [
          {
            'parameterCode': 'temperature',
            'type': 'int16',
            'endian': 'little',
            'byteOffset': 0,
            'scale': 0.1,
          },
          {
            'parameterCode': 'light',
            'type': 'uint32',
            'endian': 'little',
            'byteOffset': 3,
          },
          {
            'parameterCode': 'moisture',
            'type': 'uint8',
            'endian': 'little',
            'byteOffset': 7,
          },
          {
            'parameterCode': 'conductivity',
            'type': 'uint16',
            'endian': 'little',
            'byteOffset': 8,
          },
        ],
      },
    ],
    'goldenVectors': [
      {
        'packets': [
          [215, 0, 0, 16, 39, 0, 0, 45, 244, 1]
        ],
        'expectedValues': {
          'temperature': 21.5,
          'light': 10000,
          'moisture': 45,
          'conductivity': 500,
        },
      },
    ],
  });

  static final GattProfile doorSensor2 = GattProfile.fromJson({
    'schemaVersion': 1,
    'revision': 1,
    'sensorTypeCode': 'xiaomi_door_sensor_2',
    'minEngineVersion': 1,
    'transport': 'ble_advertisement',
    'discovery': {'advertisedServiceUuid': 'fe95'},
    'reads': [],
    'advertisement': {
      'decoderId': 'xiaomi_mibeacon_v4_v5',
      'serviceUuid': 'fe95',
      'productId': 2443,
      'timeoutMilliseconds': 10000,
      'maxPackets': 100,
      'objects': [
        {'objectId': '0x1019', 'parameterCode': 'opening', 'type': 'uint8'},
        {'objectId': '0x1018', 'parameterCode': 'light_detected', 'type': 'bool'},
        {'objectId': '0x100A', 'parameterCode': 'battery', 'type': 'uint8'},
      ],
    },
  });

  static List<GattProfile> get all => [
        xiaomi,
        kestrel,
        inkbirdIbsTh1,
        pc60fw,
        plxContinuous,
        flowerCare,
        doorSensor2,
      ];
}

class UnsupportedSensorException implements Exception {
  final String sensorTypeCode;

  const UnsupportedSensorException(this.sensorTypeCode);

  @override
  String toString() => 'Unsupported sensor type: $sensorTypeCode';
}
