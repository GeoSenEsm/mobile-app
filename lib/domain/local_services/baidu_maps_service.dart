import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

/// Service for Baidu Maps operations and coordinate transformations
class BaiduMapsService {
  // Baidu Maps tile URL template
  // This template works globally and supports both China and Europe
  static const String baiduTileUrlTemplate =
      'https://api0.map.bdimg.com/customimage/tile?x={x}&y={y}&z={z}&udt=20230101&scale=1';

  // Alternative Baidu tile URLs for load balancing
  static const String baiduTileUrlTemplate2 =
      'https://api1.map.bdimg.com/customimage/tile?x={x}&y={y}&z={z}&udt=20230101&scale=1';

  static const String baiduTileUrlTemplate3 =
      'https://api2.map.bdimg.com/customimage/tile?x={x}&y}&z={z}&udt=20230101&scale=1';

  /// MCBAND constants for Baidu coordinate conversion
  static const List<int> mcBand = [12890595.86, 8362377.87, 5591021, 3481989.83, 1678043.12, 0];
  static const List<List<int>> llBand = [
    [75, 60, 45, 30, 15, 0]
  ];

  static const List<List<int>> mcLlArray = [
    [12890595.86, 1.289059586e7, 75],
    [8362377.87, 12890595.86, 60],
    [5591021, 8362377.87, 45],
    [3481989.83, 5591021, 30],
    [1678043.12, 3481989.83, 15],
    [0, 1678043.12, 0]
  ];

  /// Convert WGS-84 (lat, lng) to Baidu Mercator coordinates
  /// This is used for internal calculations
  static Map<String, double> convertWgs84ToBaiduMercator(double latitude, double longitude) {
    final double llLat = latitude;
    final double llLng = longitude;

    // Convert to Baidu Mercator projection
    final double cF = math.pi * llLat / 180.0;
    double cE = math.log(math.tan((math.pi / 2 + cF) / 2)) * (20037508.34 / math.pi);
    double bF = llLng * 20037508.34 / 180.0;

    return {
      'x': bF,
      'y': cE,
    };
  }

  /// Convert Baidu Mercator to tile coordinates
  static Map<String, int> convertMercatorToTile(double x, double y, int z) {
    final double cE = math.pow(2.0, (18 - z)).toDouble();
    final double cF = math.pow(2.0, z).toDouble();

    final int tileX = ((x / 20037508.34 + 1) / 2 * cF).floor();
    final int tileY = ((1 - y / 20037508.34) / 2 * cF).floor();

    return {
      'x': tileX,
      'y': tileY,
    };
  }

  /// Get the Baidu tile URL for a specific zoom level and tile coordinates
  /// Uses round-robin to distribute load across Baidu's servers
  static String getBaiduTileUrl(int x, int y, int z, {int serverIndex = 0}) {
    final templates = [
      baiduTileUrlTemplate,
      baiduTileUrlTemplate2,
      baiduTileUrlTemplate3,
    ];

    final template = templates[serverIndex % templates.length];

    return template
        .replaceAll('{x}', x.toString())
        .replaceAll('{y}', y.toString())
        .replaceAll('{z}', z.toString());
  }

  /// Get the appropriate Baidu tile URL template for flutter_map
  /// Returns the primary URL template
  static String getTileUrlTemplate() {
    return baiduTileUrlTemplate;
  }

  /// Check if coordinates are valid
  static bool isValidCoordinates(double latitude, double longitude) {
    return latitude >= -90 && latitude <= 90 && longitude >= -180 && longitude <= 180;
  }

  /// Get a LatLng from WGS-84 coordinates (no transformation needed for flutter_map)
  /// flutter_map handles the display transformation internally
  static LatLng getLatLng(double latitude, double longitude) {
    if (!isValidCoordinates(latitude, longitude)) {
      throw ArgumentError('Invalid coordinates: lat=$latitude, lng=$longitude');
    }
    return LatLng(latitude, longitude);
  }

  /// Default center position for map initialization (Warsaw, Poland)
  /// Central point for both China and Europe
  static const LatLng defaultCenter = LatLng(52.2297, 21.0122);

  /// Get region-specific initial position
  /// Europe: Warsaw, Poland
  /// China: Beijing
  static LatLng getInitialPosition({required bool isChina}) {
    if (isChina) {
      return const LatLng(39.9042, 116.4074); // Beijing
    }
    return defaultCenter; // Warsaw, Poland
  }
}

