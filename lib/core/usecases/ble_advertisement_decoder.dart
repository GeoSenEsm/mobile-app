import 'dart:typed_data';

import 'package:pointycastle/export.dart';
import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';

class BleAdvertisementDecoder {
  const BleAdvertisementDecoder();

  SensorReading decode(
    GattProfile profile,
    List<int> serviceData,
    List<int> bindKey,
  ) {
    final definition = profile.advertisement;
    if (definition == null || definition.decoderId != 'xiaomi_mibeacon_v4_v5') {
      throw const AdvertisementPacketException(
          'Unsupported advertisement decoder');
    }
    if (bindKey.length != 16 || serviceData.length < 18) {
      throw const AdvertisementPacketException('Invalid encrypted packet');
    }
    final data = Uint8List.fromList(serviceData);
    final frameControl = data[0] | (data[1] << 8);
    final version = frameControl >> 12;
    if ((version != 4 && version != 5) || (frameControl & 0x0800) == 0) {
      throw const AdvertisementPacketException(
          'Unsupported MiBeacon frame');
    }
    final productId = data[2] | (data[3] << 8);
    if (productId != definition.productId) {
      throw const AdvertisementPacketException('Product mismatch');
    }

    final payload = _decryptMiBeacon(data, Uint8List.fromList(bindKey));
    return SensorReading(
      source: profile.sensorTypeCode,
      values: _decodeMiBeaconObjects(payload, definition),
    );
  }

  Uint8List _decryptMiBeacon(Uint8List frame, Uint8List bindKey) {
    final encryptedPayloadEnd = frame.length - 7;
    if (encryptedPayloadEnd <= 11) {
      throw const AdvertisementPacketException('Encrypted frame is too short');
    }
    final extendedCounter = frame.sublist(frame.length - 7, frame.length - 4);
    final mic = frame.sublist(frame.length - 4);
    final nonce = Uint8List.fromList([
      ...frame.sublist(5, 11),
      ...frame.sublist(2, 5),
      ...extendedCounter,
    ]);
    final cipherTextAndTag = Uint8List.fromList([
      ...frame.sublist(11, encryptedPayloadEnd),
      ...mic,
    ]);
    try {
      final cipher = CCMBlockCipher(AESEngine())
        ..init(
          false,
          AEADParameters(
            KeyParameter(bindKey),
            32,
            nonce,
            Uint8List.fromList(const [0x11]),
          ),
        );
      return cipher.process(cipherTextAndTag);
    } on Object {
      throw const AdvertisementPacketException(
          'Advertisement authentication failed');
    }
  }

  Map<String, num> _decodeMiBeaconObjects(
      Uint8List payload, BleAdvertisementDefinition definition) {
    final values = <String, num>{};
    final mappings = {
      for (final mapping in definition.objects) mapping.objectId: mapping,
    };
    var offset = 0;
    while (offset + 3 <= payload.length) {
      final objectId = payload[offset] | (payload[offset + 1] << 8);
      final length = payload[offset + 2];
      offset += 3;
      if (offset + length > payload.length) {
        throw const AdvertisementPacketException('Malformed object payload');
      }
      final mapping = mappings[objectId];
      if (mapping != null && length == 1) {
        final value = payload[offset];
        values[mapping.parameterCode] =
            mapping.type == 'bool' ? (value == 0 ? 0 : 1) : value;
      }
      offset += length;
    }
    if (values.isEmpty) {
      throw const AdvertisementPacketException('No supported sensor objects');
    }
    return values;
  }
}

class AdvertisementPacketException implements Exception {
  final String message;

  const AdvertisementPacketException(this.message);

  @override
  String toString() => 'AdvertisementPacketException: $message';
}
