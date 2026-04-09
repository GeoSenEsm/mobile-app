import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:survey_frontend/presentation/screens/map/map_coordinate_converter.dart';
import 'package:survey_frontend/presentation/screens/map/map_provider_type.dart';

void main() {
  group('MapCoordinateConverter', () {
    test('keeps google coordinates unchanged', () {
      const point = LatLng(52.2297, 21.0122);

      final converted =
          MapCoordinateConverter.wgs84ToProvider(point, MapProviderType.google);

      expect(converted.latitude, closeTo(point.latitude, 0.000001));
      expect(converted.longitude, closeTo(point.longitude, 0.000001));
    });

    test('keeps coordinates outside China unchanged for Baidu', () {
      const point = LatLng(52.2297, 21.0122);

      final converted =
          MapCoordinateConverter.wgs84ToProvider(point, MapProviderType.baidu);

      expect(converted.latitude, closeTo(point.latitude, 0.000001));
      expect(converted.longitude, closeTo(point.longitude, 0.000001));
    });

    test('converts Beijing coordinates for Baidu', () {
      const point = LatLng(39.908823, 116.39747);

      final converted =
          MapCoordinateConverter.wgs84ToProvider(point, MapProviderType.baidu);

      expect(converted.latitude, closeTo(39.9169, 0.02));
      expect(converted.longitude, closeTo(116.4100, 0.02));
      expect((converted.latitude - point.latitude).abs(), greaterThan(0.001));
      expect((converted.longitude - point.longitude).abs(), greaterThan(0.001));
    });
  });

  group('MapProviderType', () {
    test('falls back to google for unknown storage values', () {
      expect(mapProviderTypeFromStorage('unexpected'), MapProviderType.google);
      expect(mapProviderTypeFromStorage(null), MapProviderType.google);
    });

    test('restores known storage values', () {
      expect(mapProviderTypeFromStorage('google'), MapProviderType.google);
      expect(mapProviderTypeFromStorage('baidu'), MapProviderType.baidu);
    });
  });
}
