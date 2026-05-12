import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/core/utils/coordinate_converter.dart';
import 'package:survey_frontend/presentation/screens/map/baidu_tile_provider.dart';

void main() {
  group('CoordinateConverter', () {
    test('keeps coordinates outside China unchanged for BD-09 conversion', () {
      const latitude = 52.2297;
      const longitude = 21.0122;

      final converted = CoordinateConverter.wgs84ToBd09(latitude, longitude);

      expect(converted.$1, closeTo(latitude, 0.000001));
      expect(converted.$2, closeTo(longitude, 0.000001));
    });

    test('converts Beijing coordinates to BD-09', () {
      const latitude = 39.908823;
      const longitude = 116.39747;

      final converted = CoordinateConverter.wgs84ToBd09(latitude, longitude);

      expect(converted.$1, closeTo(39.9169, 0.02));
      expect(converted.$2, closeTo(116.4100, 0.02));
      expect((converted.$1 - latitude).abs(), greaterThan(0.001));
      expect((converted.$2 - longitude).abs(), greaterThan(0.001));
    });
  });

  group('BaiduTileCoordinateConverter', () {
    test('uses browser-compatible Baidu tile y inversion at zoom zero', () {
      final converted = BaiduTileCoordinateConverter.fromSlippy(
        x: 0,
        y: 0,
        zoom: 0,
      );

      expect(converted.x, 0);
      expect(converted.y, -1);
    });

    test('converts Flutter Baidu CRS tile coordinates to Baidu URL coordinates', () {
      final converted = BaiduTileCoordinateConverter.fromSlippy(
        x: 6743,
        y: 3101,
        zoom: 13,
      );

      expect(converted.x, 6743);
      expect(converted.y, -3102);
    });

    test('formats negative tile values numerically for maponline endpoint', () {
      expect(BaiduTileCoordinateConverter.formatBaiduTileValue(-12), '-12');
      expect(BaiduTileCoordinateConverter.formatBaiduTileValue(0), '0');
      expect(BaiduTileCoordinateConverter.formatBaiduTileValue(34), '34');
    });
  });
}

