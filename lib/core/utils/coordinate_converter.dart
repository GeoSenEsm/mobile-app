import 'dart:math';

class CoordinateConverter {
  static const double _pi = 3.1415926535897932384626;
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;

  static bool _isOutOfChina(double lat, double lng) {
    return lng < 72.004 || lng > 137.8347 || lat < 0.8293 || lat > 55.8271;
  }

  static double _transformLat(double x, double y) {
    double ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y +
        0.1 * x * y + 0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * _pi) + 40.0 * sin(y / 3.0 * _pi)) * 2.0 / 3.0;
    ret += (160.0 * sin(y / 12.0 * _pi) + 320 * sin(y * _pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLng(double x, double y) {
    double ret = 300.0 + x + 2.0 * y + 0.1 * x * x +
        0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * _pi) + 40.0 * sin(x / 3.0 * _pi)) * 2.0 / 3.0;
    ret += (150.0 * sin(x / 12.0 * _pi) + 300.0 * sin(x / 30.0 * _pi)) * 2.0 / 3.0;
    return ret;
  }

  /// WGS-84 → GCJ-02
  static (double lat, double lng) wgs84ToGcj02(double lat, double lng) {
    if (_isOutOfChina(lat, lng)) return (lat, lng);

    double dLat = _transformLat(lng - 105.0, lat - 35.0);
    double dLng = _transformLng(lng - 105.0, lat - 35.0);

    final radLat = lat / 180.0 * _pi;
    double magic = sin(radLat);
    magic = 1 - _ee * magic * magic;
    final sqrtMagic = sqrt(magic);

    dLat = (dLat * 180.0) / ((_a * (1 - _ee)) / (magic * sqrtMagic) * _pi);
    dLng = (dLng * 180.0) / (_a / sqrtMagic * cos(radLat) * _pi);

    return (lat + dLat, lng + dLng);
  }

  /// GCJ-02 → BD-09
  static (double lat, double lng) gcj02ToBd09(double lat, double lng) {
    const double xPi = _pi * 3000.0 / 180.0;
    final z = sqrt(lng * lng + lat * lat) + 0.00002 * sin(lat * xPi);
    final theta = atan2(lat, lng) + 0.000003 * cos(lng * xPi);
    return (z * sin(theta) + 0.006, z * cos(theta) + 0.0065);
  }

  /// WGS-84 → BD-09
  static (double lat, double lng) wgs84ToBd09(double lat, double lng) {
    final gcj = wgs84ToGcj02(lat, lng);
    return gcj02ToBd09(gcj.$1, gcj.$2);
  }
}
