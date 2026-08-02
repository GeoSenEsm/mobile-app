import 'dart:typed_data';

import 'package:survey_frontend/core/models/sensor_reading.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';

class GattProfileDecoder {
  const GattProfileDecoder();

  SensorReading decode(GattProfile profile, List<List<int>> packets) {
    if (packets.length != profile.reads.length) {
      throw const GattPacketException('Packet count does not match profile');
    }

    final values = <String, num>{};
    for (var index = 0; index < packets.length; index++) {
      _decodeRead(profile.reads[index], packets[index], values);
    }
    return SensorReading(source: profile.sensorTypeCode, values: values);
  }

  void validateGoldenVectors(GattProfile profile) {
    for (final vector in profile.goldenVectors) {
      final reading = decode(profile, vector.packets);
      if (!_matches(reading.values, vector.expectedValues)) {
        throw const GattProfileFormatException('Golden vector mismatch');
      }
    }
  }

  void _decodeRead(GattRead read, List<int> packet, Map<String, num> values) {
    validateFrame(read, packet);
    final data = ByteData.sublistView(Uint8List.fromList(packet));
    for (final field in read.fields) {
      if (field.byteOffset + field.byteLength > packet.length) {
        throw GattPacketException(
            '${field.parameterCode} exceeds packet length');
      }
      final raw = _readPrimitive(data, field);
      final value = raw * field.scale + field.valueOffset;
      if (!value.isFinite ||
          (field.minimum != null && value < field.minimum!) ||
          (field.maximum != null && value > field.maximum!)) {
        throw GattPacketException('${field.parameterCode} is out of range');
      }
      values[field.parameterCode] = value;
    }
  }

  void validateFrame(GattRead read, List<int> packet) {
    if (packet.length > 512 || packet.any((byte) => byte < 0 || byte > 255)) {
      throw const GattPacketException('Invalid packet bytes');
    }
    final frame = read.frame;
    if ((frame.exactLength != null && packet.length != frame.exactLength) ||
        (frame.minimumLength != null && packet.length < frame.minimumLength!) ||
        packet.length < frame.prefix.length) {
      throw const GattPacketException('Packet length constraint failed');
    }
    for (var index = 0; index < frame.prefix.length; index++) {
      if (packet[index] != frame.prefix[index]) {
        throw const GattPacketException('Packet prefix failed');
      }
    }
    if (frame.checksum == 'crc8_maxim' &&
        (packet.length < 2 ||
            crc8Maxim(packet.sublist(0, packet.length - 1)) != packet.last)) {
      throw const GattPacketException('Packet checksum failed');
    }
    for (final assertion in read.assertions) {
      final end = assertion.byteOffset + assertion.equals.length;
      if (end > packet.length) {
        throw const GattPacketException('Assertion exceeds packet length');
      }
      for (var index = 0; index < assertion.equals.length; index++) {
        if (packet[assertion.byteOffset + index] != assertion.equals[index]) {
          throw const GattPacketException('Packet assertion failed');
        }
      }
    }
  }

  int crc8Maxim(List<int> bytes) {
    var crc = 0;
    for (final byte in bytes) {
      crc ^= byte;
      for (var bit = 0; bit < 8; bit++) {
        if ((crc & 1) != 0) {
          crc = (crc >> 1) ^ 0x8c;
        } else {
          crc >>= 1;
        }
      }
    }
    return crc;
  }

  num _readPrimitive(ByteData data, GattField field) {
    final endian = field.endian == 'little' ? Endian.little : Endian.big;
    switch (field.type) {
      case 'uint8':
        return data.getUint8(field.byteOffset);
      case 'int8':
        return data.getInt8(field.byteOffset);
      case 'uint16':
        return data.getUint16(field.byteOffset, endian);
      case 'int16':
        return data.getInt16(field.byteOffset, endian);
      case 'uint32':
        return data.getUint32(field.byteOffset, endian);
      case 'int32':
        return data.getInt32(field.byteOffset, endian);
      case 'float32':
        return data.getFloat32(field.byteOffset, endian);
      case 'sfloat16':
        return _readSfloat16(data.getUint16(field.byteOffset, endian));
    }
    throw const GattProfileFormatException('Unsupported primitive type');
  }

  double _readSfloat16(int raw) {
    final mantissaBits = raw & 0x0fff;
    if (const {0x07ff, 0x0800, 0x07fe, 0x0802, 0x0801}.contains(mantissaBits)) {
      throw const GattPacketException('Reserved SFLOAT16 value');
    }
    final mantissa =
        (mantissaBits & 0x0800) == 0 ? mantissaBits : mantissaBits - 0x1000;
    final exponentBits = (raw >> 12) & 0x0f;
    final exponent =
        (exponentBits & 0x08) == 0 ? exponentBits : exponentBits - 0x10;
    return mantissa * _pow10(exponent);
  }

  double _pow10(int exponent) {
    var result = 1.0;
    if (exponent >= 0) {
      for (var index = 0; index < exponent; index++) {
        result *= 10;
      }
    } else {
      for (var index = 0; index > exponent; index--) {
        result /= 10;
      }
    }
    return result;
  }

  bool _matches(Map<String, num> actual, Map<String, num> expected) {
    if (actual.length != expected.length) return false;
    for (final entry in expected.entries) {
      final value = actual[entry.key];
      if (value == null ||
          (value.toDouble() - entry.value.toDouble()).abs() > 0.000001) {
        return false;
      }
    }
    return true;
  }
}

class GattPacketException implements Exception {
  final String message;

  const GattPacketException(this.message);

  @override
  String toString() => 'GattPacketException: $message';
}
