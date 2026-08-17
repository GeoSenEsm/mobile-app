import 'dart:typed_data';

import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/core/usecases/gatt_profile_decoder.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';

class BleAdvertisementDecoder {
  const BleAdvertisementDecoder({this.fieldDecoder = const GattProfileDecoder()});

  final GattProfileDecoder fieldDecoder;

  SensorReading decode(
    GattProfile profile,
    List<int> serviceData,
  ) {
    final definition = profile.advertisement;
    if (definition == null || !BleAdvertisementDefinition.decoderWhitelist.contains(definition.decoderId)) {
      throw const AdvertisementPacketException(
          'Unsupported advertisement decoder');
    }
    if (definition.usesFixedOffsetFields) {
      return _decodeFixedOffset(profile, definition, serviceData);
    }
    return _decodeMiBeacon(profile, definition, serviceData);
  }

  /// Ruuvi's Data Format 5 (and any future fixed-offset decoder) is a plain struct with no TLV
  /// framing, no product-id header, and no encryption — the raw bytes handed in are exactly the
  /// manufacturer-specific-data payload, ready to decode at the declared offsets.
  SensorReading _decodeFixedOffset(GattProfile profile,
      BleAdvertisementDefinition definition, List<int> payload) {
    final values = <String, num>{};
    try {
      fieldDecoder.decodeFields(definition.fields, payload, values);
    } on GattPacketException catch (exception) {
      throw AdvertisementPacketException(exception.message);
    }
    return SensorReading(source: profile.sensorTypeCode, values: values);
  }

  SensorReading _decodeMiBeacon(
    GattProfile profile,
    BleAdvertisementDefinition definition,
    List<int> serviceData,
  ) {
    if (serviceData.length < 11) {
      throw const AdvertisementPacketException(
          'Advertisement frame is too short');
    }
    final data = Uint8List.fromList(serviceData);
    final frameControl = data[0] | (data[1] << 8);
    final version = frameControl >> 12;
    if (version != 4 && version != 5) {
      throw const AdvertisementPacketException(
          'Unsupported MiBeacon frame');
    }
    final productId = data[2] | (data[3] << 8);
    if (productId != definition.productId) {
      throw const AdvertisementPacketException('Product mismatch');
    }

    // Stock firmware only encrypts advertisements once the sensor has been bound to a Mi Home
    // account; unbound devices broadcast the object payload in the clear right after the header.
    final isEncrypted = (frameControl & 0x0800) != 0;
    if (isEncrypted) {
      throw const AdvertisementPacketException(
          'Encrypted advertisement not supported');
    }
    final payload = data.sublist(11);
    return SensorReading(
      source: profile.sensorTypeCode,
      values: _decodeMiBeaconObjects(payload, definition),
    );
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
      if (mapping != null && length == mapping.byteLength) {
        values[mapping.parameterCode] = mapping.decode(payload, offset);
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
