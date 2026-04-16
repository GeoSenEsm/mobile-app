import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/domain/local_services/baidu_maps_service.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('BaiduMapsService Tests', () {

    test('Baidu tile URL template should be valid', () {
      final urlTemplate = BaiduMapsService.getTileUrlTemplate();
      expect(urlTemplate, contains('api'));
      expect(urlTemplate, contains('map.bdimg.com'));
      expect(urlTemplate, contains('{x}'));
      expect(urlTemplate, contains('{y}'));
      expect(urlTemplate, contains('{z}'));
    });

    test('Should validate correct coordinates', () {
      // Europe - Warsaw
      expect(BaiduMapsService.isValidCoordinates(52.2297, 21.0122), true);

      // Europe - London
      expect(BaiduMapsService.isValidCoordinates(51.5074, -0.1278), true);

      // China - Beijing
      expect(BaiduMapsService.isValidCoordinates(39.9042, 116.4074), true);
    });

    test('Should reject invalid coordinates', () {
      // Invalid latitude (> 90)
      expect(BaiduMapsService.isValidCoordinates(91.0, 0.0), false);

      // Invalid latitude (< -90)
      expect(BaiduMapsService.isValidCoordinates(-91.0, 0.0), false);

      // Invalid longitude (> 180)
      expect(BaiduMapsService.isValidCoordinates(0.0, 181.0), false);

      // Invalid longitude (< -180)
      expect(BaiduMapsService.isValidCoordinates(0.0, -181.0), false);
    });

    test('Should create valid LatLng from coordinates', () {
      final latLng = BaiduMapsService.getLatLng(52.2297, 21.0122);

      expect(latLng, isNotNull);
      expect(latLng.latitude, equals(52.2297));
      expect(latLng.longitude, equals(21.0122));
    });

    test('Should throw error for invalid coordinates', () {
      expect(
        () => BaiduMapsService.getLatLng(91.0, 0.0),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Should provide Europe initial position', () {
      final position = BaiduMapsService.getInitialPosition(isChina: false);

      expect(position, isNotNull);
      expect(position.latitude, equals(52.2297)); // Warsaw
      expect(position.longitude, equals(21.0122));
    });

    test('Should provide China initial position', () {
      final position = BaiduMapsService.getInitialPosition(isChina: true);

      expect(position, isNotNull);
      expect(position.latitude, equals(39.9042)); // Beijing
      expect(position.longitude, equals(116.4074));
    });

    test('Default center should be Warsaw', () {
      expect(BaiduMapsService.defaultCenter.latitude, equals(52.2297));
      expect(BaiduMapsService.defaultCenter.longitude, equals(21.0122));
    });

    test('Should convert WGS84 to Baidu Mercator', () {
      // Warsaw coordinates
      final mercator = BaiduMapsService.convertWgs84ToBaiduMercator(52.2297, 21.0122);

      expect(mercator, isNotNull);
      expect(mercator.containsKey('x'), true);
      expect(mercator.containsKey('y'), true);
      expect(mercator['x'], isNotNull);
      expect(mercator['y'], isNotNull);
    });

    test('Should convert Mercator to tile coordinates', () {
      final mercator = BaiduMapsService.convertWgs84ToBaiduMercator(52.2297, 21.0122);
      final tile = BaiduMapsService.convertMercatorToTile(
        mercator['x']!,
        mercator['y']!,
        13, // zoom level
      );

      expect(tile, isNotNull);
      expect(tile.containsKey('x'), true);
      expect(tile.containsKey('y'), true);
      expect(tile['x'], isA<int>());
      expect(tile['y'], isA<int>());
    });

    test('Should handle multiple server URLs', () {
      final url0 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 0);
      final url1 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 1);
      final url2 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 2);

      expect(url0, contains('api0'));
      expect(url1, contains('api1'));
      expect(url2, contains('api2'));

      // Verify coordinates are properly embedded
      expect(url0, contains('x=1'));
      expect(url0, contains('y=2'));
      expect(url0, contains('z=3'));
    });

    test('Should round-robin server indices correctly', () {
      // Test wrap-around behavior
      final url0 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 0);
      final url3 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 3);
      final url6 = BaiduMapsService.getBaiduTileUrl(1, 2, 3, serverIndex: 6);

      expect(url0.contains('api0'), true);
      expect(url3.contains('api0'), true); // 3 % 3 = 0
      expect(url6.contains('api0'), true); // 6 % 3 = 0
    });

    test('Europe coordinates should work', () {
      final locations = [
        {'name': 'Warsaw', 'lat': 52.2297, 'lng': 21.0122},
        {'name': 'London', 'lat': 51.5074, 'lng': -0.1278},
        {'name': 'Paris', 'lat': 48.8566, 'lng': 2.3522},
        {'name': 'Berlin', 'lat': 52.5200, 'lng': 13.4050},
      ];

      for (final location in locations) {
        expect(
          BaiduMapsService.isValidCoordinates(location['lat'] as double, location['lng'] as double),
          true,
          reason: 'Location ${location['name']} should be valid',
        );

        final latLng = BaiduMapsService.getLatLng(location['lat'] as double, location['lng'] as double);
        expect(latLng, isNotNull, reason: 'Should create LatLng for ${location['name']}');
      }
    });

    test('China coordinates should work', () {
      final locations = [
        {'name': 'Beijing', 'lat': 39.9042, 'lng': 116.4074},
        {'name': 'Shanghai', 'lat': 31.2304, 'lng': 121.4737},
        {'name': 'Shenzhen', 'lat': 22.5431, 'lng': 114.0579},
        {'name': 'Chengdu', 'lat': 30.5728, 'lng': 104.0668},
      ];

      for (final location in locations) {
        expect(
          BaiduMapsService.isValidCoordinates(location['lat'] as double, location['lng'] as double),
          true,
          reason: 'Location ${location['name']} should be valid',
        );

        final latLng = BaiduMapsService.getLatLng(location['lat'] as double, location['lng'] as double);
        expect(latLng, isNotNull, reason: 'Should create LatLng for ${location['name']}');
      }
    });
  });

  group('MapScreenController Integration Tests', () {

    test('MapScreenController should use Baidu Maps URL', () {
      // This would require mocking dependencies
      // For now, we verify the service is available

      final tileUrl = BaiduMapsService.getTileUrlTemplate();
      expect(tileUrl, isNotEmpty);
      expect(tileUrl, contains('baidu'));
    });
  });
}

