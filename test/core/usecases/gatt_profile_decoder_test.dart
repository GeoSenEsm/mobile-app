import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/core/usecases/gatt_profile_decoder.dart';
import 'package:survey_frontend/domain/models/gatt_profile.dart';

void main() {
  const decoder = GattProfileDecoder();

  test('decodes every bounded primitive with endian and transforms', () {
    final bytes = BytesBuilder()
      ..add([255, 254])
      ..add(_bytes((data) => data.setUint16(0, 500, Endian.little), 2))
      ..add(_bytes((data) => data.setInt16(0, -200, Endian.big), 2))
      ..add(_bytes((data) => data.setUint32(0, 4000000000, Endian.little), 4))
      ..add(_bytes((data) => data.setInt32(0, -300000, Endian.big), 4))
      ..add(_bytes((data) => data.setFloat32(0, 2.5, Endian.little), 4));
    final profile = _profile([
      _field('u8', 'uint8', 0),
      _field('i8', 'int8', 1),
      _field('u16', 'uint16', 2, endian: 'little'),
      _field('i16', 'int16', 4),
      _field('u32', 'uint32', 6, endian: 'little'),
      _field('i32', 'int32', 10),
      _field('f32', 'float32', 14, endian: 'little', scale: 2, valueOffset: 1),
    ]);

    final reading = decoder.decode(profile, [bytes.toBytes()]);

    expect(reading.source, 'test');
    expect(reading.values, {
      'u8': 255,
      'i8': -2,
      'u16': 500,
      'i16': -200,
      'u32': 4000000000,
      'i32': -300000,
      'f32': 6,
    });
    // Dart's `==` treats 6 == 6.0 as true, so the map equality above would pass even if
    // whole-number collapsing (_asIntegerIfWhole) were broken. Assert the runtime type
    // directly so a regression there (e.g. serializing "6.0" instead of "6") fails this test.
    for (final entry in reading.values.entries) {
      expect(entry.value, isA<int>(),
          reason: 'GATT field ${entry.key} is whole-valued and should decode to int, not double');
    }
  });

  test('rejects short packets, failed assertions, and out-of-range values', () {
    final short = _profile([_field('value', 'uint16', 0)]);
    expect(
        () => decoder.decode(short, const [
              [1]
            ]),
        throwsA(isA<GattPacketException>()));

    final asserted = _profile(
      [_field('value', 'uint8', 1)],
      assertions: const [
        GattByteAssertion(byteOffset: 0, equals: [7])
      ],
    );
    expect(
        () => decoder.decode(asserted, const [
              [8, 1]
            ]),
        throwsA(isA<GattPacketException>()));

    final ranged = _profile([
      GattField(
        parameterCode: 'value',
        type: 'uint8',
        endian: 'big',
        byteOffset: 0,
        maximum: 10,
      ),
    ]);
    expect(
        () => decoder.decode(ranged, const [
              [11]
            ]),
        throwsA(isA<GattPacketException>()));
  });

  test('exactLength tolerates a trailing next frame batched into the same notification', () {
    // Some devices (e.g. Contec-style pulse oximeters) pack more than one logical frame into a
    // single BLE notification. A valid 12-byte frame followed by the start of the next one must
    // still decode — exactLength means "at least this many bytes, only the first N matter".
    final profile = _profile(
      [
        _field('spo2', 'uint8', 5),
        _field('pulse_rate', 'uint8', 6),
      ],
      frame: const GattFrame(exactLength: 12, checksum: 'crc8_maxim'),
    );
    final frame = [0xaa, 0x55, 0x0f, 0x08, 0x01, 0x60, 0x39, 0x00, 0x8e, 0x00, 0xc0];
    final withChecksum = [...frame, decoder.crc8Maxim(frame)];
    final withTrailingNextFrame = [...withChecksum, 0xaa, 0x55, 0x0f, 0x07, 0x02, 0x7f];

    final reading = decoder.decode(profile, [withTrailingNextFrame]);

    expect(reading.values, {'spo2': 96, 'pulse_rate': 57});
  });

  test('rejects unknown schema and engine versions', () {
    final json = _profile([_field('value', 'uint8', 0)]).toJson();
    expect(
      () => GattProfile.fromJson({...json, 'schemaVersion': 2}),
      throwsA(isA<GattProfileFormatException>()),
    );
    expect(
      () => GattProfile.fromJson({...json, 'minEngineVersion': 2}),
      throwsA(isA<GattProfileFormatException>()),
    );
  });

  test('profile serialization round-trips without losing golden vectors', () {
    final profile = GattProfile.fromJson({
      ..._profile([_field('value', 'uint8', 0)]).toJson(),
      'goldenVectors': [
        {
          'packets': [
            [5]
          ],
          'expectedValues': {'value': 5}
        }
      ],
    });

    final restored = GattProfile.fromJson(profile.toJson());

    expect(restored.toJson(), profile.toJson());
    expect(() => decoder.validateGoldenVectors(restored), returnsNormally);
  });

  test('validates CRC8 Maxim and decodes IEEE-11073 SFLOAT16', () {
    final profile = _profile([
      _field('value', 'sfloat16', 0, endian: 'little'),
    ]);
    final payload = [0xd7, 0xf0];
    final read = GattRead(
      serviceUuid: profile.reads.single.serviceUuid,
      characteristicUuid: profile.reads.single.characteristicUuid,
      assertions: const [],
      frame: const GattFrame(checksum: 'crc8_maxim'),
      fields: profile.reads.single.fields,
    );
    final checksummed = [...payload, decoder.crc8Maxim(payload)];
    final checksummedProfile = GattProfile(
      schemaVersion: 1,
      revision: 1,
      sensorTypeCode: 'test',
      minEngineVersion: 1,
      discovery: profile.discovery,
      reads: [read],
    )..validate();

    expect(decoder.decode(checksummedProfile, [checksummed]).values['value'],
        closeTo(21.5, 0.000001));
    expect(
      () => decoder.decode(checksummedProfile, [
        [...payload, checksummed.last ^ 0xff]
      ]),
      throwsA(isA<GattPacketException>()),
    );
  });
}

GattProfile _profile(
  List<GattField> fields, {
  List<GattByteAssertion> assertions = const [],
  GattFrame frame = const GattFrame(),
}) {
  return GattProfile(
    schemaVersion: 1,
    revision: 1,
    sensorTypeCode: 'test',
    minEngineVersion: 1,
    discovery: const GattDiscovery(exactName: 'TEST'),
    reads: [
      GattRead(
        serviceUuid: '00000000-0000-0000-0000-000000000001',
        characteristicUuid: '00000000-0000-0000-0000-000000000002',
        assertions: assertions,
        frame: frame,
        fields: fields,
      )
    ],
  )..validate();
}

GattField _field(
  String code,
  String type,
  int offset, {
  String endian = 'big',
  double scale = 1,
  double valueOffset = 0,
}) =>
    GattField(
      parameterCode: code,
      type: type,
      endian: endian,
      byteOffset: offset,
      scale: scale,
      valueOffset: valueOffset,
    );

List<int> _bytes(void Function(ByteData data) write, int length) {
  final data = ByteData(length);
  write(data);
  return data.buffer.asUint8List();
}
