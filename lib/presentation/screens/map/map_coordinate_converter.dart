import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:survey_frontend/presentation/screens/map/map_provider_type.dart';

class MapCoordinateConverter {
  static const double _earthSemiMajorAxis = 6378245.0;
  static const double _eccentricity = 0.00669342162296594323;
  static const double _xPi = pi * 3000.0 / 180.0;

  static LatLng wgs84ToProvider(LatLng point, MapProviderType provider) {
    return switch (provider) {
      MapProviderType.google => point,
      MapProviderType.baidu => wgs84ToBd09(point),
    };
  }

  static LatLng wgs84ToBd09(LatLng point) {
    if (_isOutsideChina(point.latitude, point.longitude)) {
      return point;
    }

    final gcj02 = _wgs84ToGcj02(point);
    final x = gcj02.longitude;
    final y = gcj02.latitude;
    final z = sqrt(x * x + y * y) + 0.00002 * sin(y * _xPi);
    final theta = atan2(y, x) + 0.000003 * cos(x * _xPi);
    final bdLongitude = z * cos(theta) + 0.0065;
    final bdLatitude = z * sin(theta) + 0.006;
    return LatLng(bdLatitude, bdLongitude);
  }

  static LatLng _wgs84ToGcj02(LatLng point) {
    final latitude = point.latitude;
    final longitude = point.longitude;
    final latitudeDelta = _transformLatitude(longitude - 105.0, latitude - 35.0);
    final longitudeDelta =
        _transformLongitude(longitude - 105.0, latitude - 35.0);
    final latitudeRadians = latitude / 180.0 * pi;
    var magic = sin(latitudeRadians);
    magic = 1 - _eccentricity * magic * magic;
    final sqrtMagic = sqrt(magic);
    final adjustedLatitude = latitude +
        (latitudeDelta * 180.0) /
            ((_earthSemiMajorAxis * (1 - _eccentricity)) /
                (magic * sqrtMagic) *
                pi);
    final adjustedLongitude = longitude +
        (longitudeDelta * 180.0) /
            (_earthSemiMajorAxis / sqrtMagic * cos(latitudeRadians) * pi);
    return LatLng(adjustedLatitude, adjustedLongitude);
  }

  static bool _isOutsideChina(double latitude, double longitude) {
    return longitude < 72.004 ||
        longitude > 137.8347 ||
        latitude < 0.8293 ||
        latitude > 55.8271;
  }

  static double _transformLatitude(double x, double y) {
    var result = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * sqrt(x.abs());
    result += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    result += (20.0 * sin(y * pi) + 40.0 * sin(y / 3.0 * pi)) * 2.0 / 3.0;
    result += (160.0 * sin(y / 12.0 * pi) + 320 * sin(y * pi / 30.0)) * 2.0 / 3.0;
    return result;
  }

  static double _transformLongitude(double x, double y) {
    var result = 300.0 +
        x +
        2.0 * y +
        0.1 * x * x +
        0.1 * x * y +
        0.1 * sqrt(x.abs());
    result += (20.0 * sin(6.0 * x * pi) + 20.0 * sin(2.0 * x * pi)) * 2.0 / 3.0;
    result += (20.0 * sin(x * pi) + 40.0 * sin(x / 3.0 * pi)) * 2.0 / 3.0;
    result += (150.0 * sin(x / 12.0 * pi) + 300.0 * sin(x / 30.0 * pi)) * 2.0 / 3.0;
    return result;
  }
}
