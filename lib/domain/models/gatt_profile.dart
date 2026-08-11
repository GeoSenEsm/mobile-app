import 'dart:typed_data';

class GattProfile {
  static const int supportedSchemaVersion = 1;
  static const int engineVersion = 1;
  static const int maxReads = 16;
  static const int maxAssertionsPerRead = 16;
  static const int maxFieldsPerRead = 32;
  static const int maxGoldenVectors = 32;

  final int schemaVersion;
  final int revision;
  final String sensorTypeCode;
  final int minEngineVersion;
  final String transport;
  final GattDiscovery discovery;
  final List<GattAction> actions;
  final List<GattRead> reads;
  final BleAdvertisementDefinition? advertisement;
  final List<GattGoldenVector> goldenVectors;

  const GattProfile({
    required this.schemaVersion,
    required this.revision,
    required this.sensorTypeCode,
    required this.minEngineVersion,
    this.transport = 'gatt_sequence',
    required this.discovery,
    this.actions = const [],
    required this.reads,
    this.advertisement,
    this.goldenVectors = const [],
  });

  factory GattProfile.fromJson(Map<String, dynamic> json) {
    final profile = GattProfile(
      schemaVersion: _requiredInt(json, 'schemaVersion'),
      revision: _requiredInt(json, 'revision'),
      sensorTypeCode: _requiredString(json, 'sensorTypeCode'),
      minEngineVersion: _requiredInt(json, 'minEngineVersion'),
      transport: json['transport'] as String? ?? 'gatt_sequence',
      discovery: GattDiscovery.fromJson(_requiredMap(json, 'discovery')),
      actions: (json['actions'] as List<dynamic>? ?? const [])
          .map((value) => GattAction.fromJson(_asMap(value, 'actions')))
          .toList(growable: false),
      reads: (json['reads'] as List<dynamic>? ?? const [])
          .map((value) => GattRead.fromJson(_asMap(value, 'reads')))
          .toList(growable: false),
      advertisement: json['advertisement'] == null
          ? null
          : BleAdvertisementDefinition.fromJson(
              _asMap(json['advertisement'], 'advertisement')),
      goldenVectors: (json['goldenVectors'] as List<dynamic>? ?? const [])
          .map((value) =>
              GattGoldenVector.fromJson(_asMap(value, 'goldenVectors')))
          .toList(growable: false),
    );
    profile.validate();
    return profile;
  }

  void validate() {
    if (schemaVersion != supportedSchemaVersion) {
      throw const GattProfileFormatException('Unsupported schemaVersion');
    }
    if (minEngineVersion > engineVersion) {
      throw const GattProfileFormatException('Unsupported minEngineVersion');
    }
    if (revision < 1 ||
        sensorTypeCode.isEmpty ||
        !const {'gatt_sequence', 'ble_advertisement'}.contains(transport)) {
      throw const GattProfileFormatException('Invalid profile identity');
    }
    discovery.validate();
    if (actions.length > 16 ||
        reads.length > maxReads ||
        (transport == 'gatt_sequence' && reads.isEmpty) ||
        (transport == 'ble_advertisement' &&
            (advertisement == null ||
                reads.isNotEmpty ||
                actions.isNotEmpty))) {
      throw const GattProfileFormatException('Invalid read count');
    }
    for (final action in actions) {
      action.validate();
    }
    advertisement?.validate();
    if (goldenVectors.length > maxGoldenVectors) {
      throw const GattProfileFormatException('Too many golden vectors');
    }
    final parameterCodes = <String>{};
    for (final read in reads) {
      read.validate();
      for (final field in read.fields) {
        if (!parameterCodes.add(field.parameterCode)) {
          throw const GattProfileFormatException('Duplicate parameterCode');
        }
      }
    }
    for (final vector in goldenVectors) {
      vector.validate(transport == 'ble_advertisement' ? 1 : reads.length);
    }
  }

  Map<String, dynamic> toJson() => {
        'schemaVersion': schemaVersion,
        'revision': revision,
        'sensorTypeCode': sensorTypeCode,
        'minEngineVersion': minEngineVersion,
        'transport': transport,
        'discovery': discovery.toJson(),
        'actions': actions.map((action) => action.toJson()).toList(),
        'reads': reads.map((read) => read.toJson()).toList(),
        if (advertisement != null) 'advertisement': advertisement!.toJson(),
        'goldenVectors':
            goldenVectors.map((vector) => vector.toJson()).toList(),
      };
}

class GattAction {
  final String type;
  final String? serviceUuid;
  final String? characteristicUuid;
  final List<int> value;
  final int? milliseconds;

  const GattAction._({
    required this.type,
    this.serviceUuid,
    this.characteristicUuid,
    this.value = const [],
    this.milliseconds,
  });

  factory GattAction.fromJson(Map<String, dynamic> json) {
    final type = _requiredString(json, 'type');
    if (type == 'write') {
      return GattAction._(
        type: type,
        serviceUuid: _requiredUuid(json, 'serviceUuid'),
        characteristicUuid: _requiredUuid(json, 'characteristicUuid'),
        value: _requiredList(json, 'value')
            .map((byte) => byte as int)
            .toList(growable: false),
      );
    }
    return GattAction._(
      type: type,
      milliseconds: _requiredInt(json, 'milliseconds'),
    );
  }

  void validate() {
    final validWrite = type == 'write' &&
        serviceUuid != null &&
        characteristicUuid != null &&
        value.isNotEmpty &&
        value.length <= 64 &&
        value.every((byte) => byte >= 0 && byte <= 255);
    final validDelay = type == 'delay' &&
        milliseconds != null &&
        milliseconds! >= 0 &&
        milliseconds! <= 10000;
    if (!validWrite && !validDelay) {
      throw const GattProfileFormatException('Invalid GATT action');
    }
  }

  Map<String, dynamic> toJson() => type == 'write'
      ? {
          'type': type,
          'serviceUuid': serviceUuid,
          'characteristicUuid': characteristicUuid,
          'value': value,
        }
      : {'type': type, 'milliseconds': milliseconds};
}

class BleAdvertisementDefinition {
  static const decoderWhitelist = {'xiaomi_mibeacon_v4_v5'};

  final String decoderId;
  final String dataSource;
  final String? serviceUuid;
  final int? manufacturerId;
  final int productId;
  final int timeoutMilliseconds;
  final int maxPackets;
  final List<BleAdvertisementObjectMapping> objects;

  const BleAdvertisementDefinition({
    required this.decoderId,
    this.dataSource = 'service_data',
    this.serviceUuid,
    this.manufacturerId,
    required this.productId,
    this.timeoutMilliseconds = 10000,
    this.maxPackets = 50,
    this.objects = const [],
  });

  factory BleAdvertisementDefinition.fromJson(Map<String, dynamic> json) =>
      BleAdvertisementDefinition(
        decoderId: _requiredString(json, 'decoderId'),
        dataSource: json['dataSource'] as String? ?? 'service_data',
        serviceUuid: json['serviceUuid'] == null
            ? null
            : _requiredUuid(json, 'serviceUuid'),
        manufacturerId: json['manufacturerId'] as int?,
        productId: _requiredInt(json, 'productId'),
        timeoutMilliseconds: json['timeoutMilliseconds'] as int? ?? 10000,
        maxPackets: json['maxPackets'] as int? ?? 50,
        objects: (json['objects'] as List<dynamic>? ?? const [])
            .map((value) =>
                BleAdvertisementObjectMapping.fromJson(_asMap(value, 'objects')))
            .toList(growable: false),
      );

  void validate() {
    if (!decoderWhitelist.contains(decoderId) ||
        !const {'service_data', 'manufacturer_data'}.contains(dataSource) ||
        (dataSource == 'service_data' && serviceUuid == null) ||
        (dataSource == 'manufacturer_data' &&
            (manufacturerId == null ||
                manufacturerId! < 0 ||
                manufacturerId! > 0xffff)) ||
        productId < 0 ||
        productId > 0xffff ||
        timeoutMilliseconds < 100 ||
        timeoutMilliseconds > 120000 ||
        maxPackets < 1 ||
        maxPackets > 500 ||
        objects.length > 32) {
      throw const GattProfileFormatException(
          'Invalid advertisement definition');
    }
    for (final object in objects) {
      object.validate();
    }
  }

  Map<String, dynamic> toJson() => {
        'decoderId': decoderId,
        'dataSource': dataSource,
        if (serviceUuid != null) 'serviceUuid': serviceUuid,
        if (manufacturerId != null) 'manufacturerId': manufacturerId,
        'productId': productId,
        'timeoutMilliseconds': timeoutMilliseconds,
        'maxPackets': maxPackets,
        'objects': objects.map((object) => object.toJson()).toList(),
      };
}

class BleAdvertisementObjectMapping {
  static const supportedTypes = {'uint8', 'int8', 'uint16', 'int16', 'bool'};

  final int objectId;
  final String parameterCode;
  final String type;
  final double scale;

  const BleAdvertisementObjectMapping({
    required this.objectId,
    required this.parameterCode,
    required this.type,
    this.scale = 1,
  });

  factory BleAdvertisementObjectMapping.fromJson(Map<String, dynamic> json) {
    final objectId = json['objectId'];
    return BleAdvertisementObjectMapping(
      objectId: objectId is String
          ? int.parse(objectId.toLowerCase().replaceFirst('0x', ''), radix: 16)
          : _requiredInt(json, 'objectId'),
      parameterCode: json['parameterCode'] as String? ??
          _requiredString(json, 'parameter'),
      type: _requiredString(json, 'type'),
      scale: (json['scale'] as num?)?.toDouble() ?? 1,
    );
  }

  void validate() {
    if (objectId < 0 ||
        objectId > 0xffff ||
        parameterCode.isEmpty ||
        !supportedTypes.contains(type) ||
        !scale.isFinite) {
      throw const GattProfileFormatException(
          'Invalid advertisement object mapping');
    }
  }

  int get byteLength => type == 'uint16' || type == 'int16' ? 2 : 1;

  num decode(Uint8List payload, int offset) {
    final num raw;
    switch (type) {
      case 'bool':
        raw = payload[offset] == 0 ? 0 : 1;
      case 'int8':
        raw = payload[offset].toSigned(8);
      case 'uint16':
        raw = payload[offset] | (payload[offset + 1] << 8);
      case 'int16':
        raw = (payload[offset] | (payload[offset + 1] << 8)).toSigned(16);
      default:
        raw = payload[offset];
    }
    return scale == 1 ? raw : raw * scale;
  }

  Map<String, dynamic> toJson() => {
        'objectId': objectId,
        'parameterCode': parameterCode,
        'type': type,
        'scale': scale,
      };
}

class GattDiscovery {
  final String? exactName;
  final String? namePrefix;
  final String? advertisedServiceUuid;

  const GattDiscovery({
    this.exactName,
    this.namePrefix,
    this.advertisedServiceUuid,
  });

  factory GattDiscovery.fromJson(Map<String, dynamic> json) => GattDiscovery(
        exactName: json['exactName'] as String?,
        namePrefix: json['namePrefix'] as String?,
        advertisedServiceUuid:
            _optionalUuid(json['advertisedServiceUuid'] as String?),
      );

  void validate() {
    if ((exactName == null || exactName!.isEmpty) &&
        (namePrefix == null || namePrefix!.isEmpty) &&
        advertisedServiceUuid == null) {
      throw const GattProfileFormatException(
          'Discovery requires a name or advertised service');
    }
    if (exactName != null && namePrefix != null) {
      throw const GattProfileFormatException(
          'Discovery name match is ambiguous');
    }
  }

  Map<String, dynamic> toJson() => {
        if (exactName != null) 'exactName': exactName,
        if (namePrefix != null) 'namePrefix': namePrefix,
        if (advertisedServiceUuid != null)
          'advertisedServiceUuid': advertisedServiceUuid,
      };
}

class GattRead {
  final String serviceUuid;
  final String characteristicUuid;
  final GattAcquisition acquisition;
  final GattFrame frame;
  final List<GattByteAssertion> assertions;
  final List<GattField> fields;

  const GattRead({
    required this.serviceUuid,
    required this.characteristicUuid,
    this.acquisition = const GattAcquisition(),
    this.frame = const GattFrame(),
    required this.assertions,
    required this.fields,
  });

  factory GattRead.fromJson(Map<String, dynamic> json) => GattRead(
        serviceUuid: _requiredUuid(json, 'serviceUuid'),
        characteristicUuid: _requiredUuid(json, 'characteristicUuid'),
        acquisition: json['acquisition'] == null
            ? const GattAcquisition()
            : GattAcquisition.fromJson(
                _asMap(json['acquisition'], 'acquisition')),
        frame: json['frame'] == null
            ? const GattFrame()
            : GattFrame.fromJson(_asMap(json['frame'], 'frame')),
        assertions: (json['assertions'] as List<dynamic>? ?? const [])
            .map((value) =>
                GattByteAssertion.fromJson(_asMap(value, 'assertions')))
            .toList(growable: false),
        fields: _requiredList(json, 'fields')
            .map((value) => GattField.fromJson(_asMap(value, 'fields')))
            .toList(growable: false),
      );

  void validate() {
    if (assertions.length > GattProfile.maxAssertionsPerRead ||
        fields.isEmpty ||
        fields.length > GattProfile.maxFieldsPerRead) {
      throw const GattProfileFormatException('Invalid read definition size');
    }
    acquisition.validate();
    frame.validate();
    for (final assertion in assertions) {
      assertion.validate();
    }
    for (final field in fields) {
      field.validate();
    }
  }

  Map<String, dynamic> toJson() => {
        'serviceUuid': serviceUuid,
        'characteristicUuid': characteristicUuid,
        'acquisition': acquisition.toJson(),
        'frame': frame.toJson(),
        'assertions':
            assertions.map((assertion) => assertion.toJson()).toList(),
        'fields': fields.map((field) => field.toJson()).toList(),
      };
}

class GattAcquisition {
  static const supportedModes = {'read', 'notification', 'indication'};

  final String mode;
  final int timeoutMilliseconds;
  final int maxPackets;

  const GattAcquisition({
    this.mode = 'read',
    this.timeoutMilliseconds = 5000,
    this.maxPackets = 1,
  });

  factory GattAcquisition.fromJson(Map<String, dynamic> json) =>
      GattAcquisition(
        mode: json['mode'] as String? ?? 'read',
        timeoutMilliseconds: json['timeoutMilliseconds'] as int? ?? 5000,
        maxPackets: json['maxPackets'] as int? ?? 1,
      );

  void validate() {
    if (!supportedModes.contains(mode) ||
        timeoutMilliseconds < 100 ||
        timeoutMilliseconds > 120000 ||
        maxPackets < 1 ||
        maxPackets > 100) {
      throw const GattProfileFormatException('Invalid acquisition bounds');
    }
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'timeoutMilliseconds': timeoutMilliseconds,
        'maxPackets': maxPackets,
      };
}

class GattFrame {
  static const supportedChecksums = {'none', 'crc8_maxim'};

  final int? exactLength;
  final int? minimumLength;
  final List<int> prefix;
  final String checksum;

  const GattFrame({
    this.exactLength,
    this.minimumLength,
    this.prefix = const [],
    this.checksum = 'none',
  });

  factory GattFrame.fromJson(Map<String, dynamic> json) => GattFrame(
        exactLength: json['exactLength'] as int?,
        minimumLength: json['minimumLength'] as int?,
        prefix: (json['prefix'] as List<dynamic>? ?? const [])
            .map((value) => value as int)
            .toList(growable: false),
        checksum: json['checksum'] as String? ?? 'none',
      );

  void validate() {
    if ((exactLength != null && (exactLength! < 1 || exactLength! > 512)) ||
        (minimumLength != null &&
            (minimumLength! < 1 || minimumLength! > 512)) ||
        (exactLength != null &&
            minimumLength != null &&
            exactLength! < minimumLength!) ||
        prefix.length > 32 ||
        prefix.any((value) => value < 0 || value > 255) ||
        !supportedChecksums.contains(checksum)) {
      throw const GattProfileFormatException('Invalid frame constraints');
    }
  }

  Map<String, dynamic> toJson() => {
        if (exactLength != null) 'exactLength': exactLength,
        if (minimumLength != null) 'minimumLength': minimumLength,
        if (prefix.isNotEmpty) 'prefix': prefix,
        'checksum': checksum,
      };
}

class GattByteAssertion {
  final int byteOffset;
  final List<int> equals;

  const GattByteAssertion({
    required this.byteOffset,
    required this.equals,
  });

  factory GattByteAssertion.fromJson(Map<String, dynamic> json) =>
      GattByteAssertion(
        byteOffset: _requiredInt(json, 'byteOffset'),
        equals: _requiredList(json, 'equals')
            .map((value) => value as int)
            .toList(growable: false),
      );

  void validate() {
    if (byteOffset < 0 ||
        equals.isEmpty ||
        equals.any((value) => value < 0 || value > 255)) {
      throw const GattProfileFormatException('Invalid byte assertion');
    }
  }

  Map<String, dynamic> toJson() => {
        'byteOffset': byteOffset,
        'equals': equals,
      };
}

class GattField {
  static const supportedTypes = {
    'uint8',
    'int8',
    'uint16',
    'int16',
    'uint32',
    'int32',
    'float32',
    'sfloat16',
  };
  static const supportedEndians = {'little', 'big'};

  final String parameterCode;
  final String type;
  final String endian;
  final int byteOffset;
  final double scale;
  final double valueOffset;
  final double? minimum;
  final double? maximum;

  const GattField({
    required this.parameterCode,
    required this.type,
    required this.endian,
    required this.byteOffset,
    this.scale = 1,
    this.valueOffset = 0,
    this.minimum,
    this.maximum,
  });

  factory GattField.fromJson(Map<String, dynamic> json) => GattField(
        parameterCode: _requiredString(json, 'parameterCode'),
        type: _requiredString(json, 'type'),
        endian: _requiredString(json, 'endian'),
        byteOffset: _requiredInt(json, 'byteOffset'),
        scale: (json['scale'] as num?)?.toDouble() ?? 1,
        valueOffset: (json['valueOffset'] as num?)?.toDouble() ?? 0,
        minimum: (json['minimum'] as num?)?.toDouble(),
        maximum: (json['maximum'] as num?)?.toDouble(),
      );

  void validate() {
    if (parameterCode.isEmpty ||
        !supportedTypes.contains(type) ||
        !supportedEndians.contains(endian) ||
        byteOffset < 0 ||
        !scale.isFinite ||
        !valueOffset.isFinite ||
        (minimum != null && !minimum!.isFinite) ||
        (maximum != null && !maximum!.isFinite) ||
        (minimum != null && maximum != null && minimum! > maximum!)) {
      throw const GattProfileFormatException('Invalid field definition');
    }
  }

  int get byteLength {
    switch (type) {
      case 'uint8':
      case 'int8':
        return 1;
      case 'uint16':
      case 'int16':
      case 'sfloat16':
        return 2;
      default:
        return 4;
    }
  }

  Map<String, dynamic> toJson() => {
        'parameterCode': parameterCode,
        'type': type,
        'endian': endian,
        'byteOffset': byteOffset,
        'scale': scale,
        'valueOffset': valueOffset,
        if (minimum != null) 'minimum': minimum,
        if (maximum != null) 'maximum': maximum,
      };
}

class GattGoldenVector {
  final List<List<int>> packets;
  final Map<String, num> expectedValues;

  const GattGoldenVector({
    required this.packets,
    required this.expectedValues,
  });

  factory GattGoldenVector.fromJson(Map<String, dynamic> json) =>
      GattGoldenVector(
        packets: _requiredList(json, 'packets')
            .map((packet) => (packet as List<dynamic>)
                .map((byte) => byte as int)
                .toList(growable: false))
            .toList(growable: false),
        expectedValues: _requiredMap(json, 'expectedValues').map((key, value) {
          if (value is! num) {
            throw const GattProfileFormatException(
                'Golden value must be numeric');
          }
          return MapEntry(key, value);
        }),
      );

  void validate(int readCount) {
    if (packets.length != readCount ||
        packets.any((packet) =>
            packet.isEmpty ||
            packet.length > 512 ||
            packet.any((byte) => byte < 0 || byte > 255))) {
      throw const GattProfileFormatException('Invalid golden vector');
    }
  }

  Map<String, dynamic> toJson() => {
        'packets': packets,
        'expectedValues': expectedValues,
      };
}

class GattProfileFormatException implements Exception {
  final String message;

  const GattProfileFormatException(this.message);

  @override
  String toString() => 'GattProfileFormatException: $message';
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  return _asMap(json[key], key);
}

Map<String, dynamic> _asMap(dynamic value, String key) {
  if (value is! Map<String, dynamic>) {
    throw GattProfileFormatException('$key must be an object');
  }
  return value;
}

List<dynamic> _requiredList(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! List<dynamic>) {
    throw GattProfileFormatException('$key must be an array');
  }
  return value;
}

int _requiredInt(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! int) {
    throw GattProfileFormatException('$key must be an integer');
  }
  return value;
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.isEmpty) {
    throw GattProfileFormatException('$key must be a non-empty string');
  }
  return value;
}

String _requiredUuid(Map<String, dynamic> json, String key) {
  final value = _requiredString(json, key).toLowerCase();
  if (_shortUuidPattern.hasMatch(value)) {
    return '0000$value-0000-1000-8000-00805f9b34fb';
  }
  if (!_uuidPattern.hasMatch(value)) {
    throw GattProfileFormatException('$key must be a UUID');
  }
  return value;
}

String? _optionalUuid(String? value) {
  if (value == null) return null;
  final normalized = value.toLowerCase();
  if (_shortUuidPattern.hasMatch(normalized)) {
    return '0000$normalized-0000-1000-8000-00805f9b34fb';
  }
  if (!_uuidPattern.hasMatch(normalized)) {
    throw const GattProfileFormatException(
        'advertisedServiceUuid must be a UUID');
  }
  return normalized;
}

final RegExp _uuidPattern =
    RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$');
final RegExp _shortUuidPattern = RegExp(r'^[0-9a-f]{4}$');
