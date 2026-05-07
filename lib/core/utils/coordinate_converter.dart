import 'dart:math';

class CoordinateConverter {
  static const double _pi = 3.1415926535897932384626;
  static const double _a = 6378245.0;
  static const double _ee = 0.00669342162296594323;
  static const List<double> _mcBand = [
    12890594.86,
    8362377.87,
    5591021,
    3481989.83,
    1678043.12,
    0
  ];
  static const List<double> _llBand = [75, 60, 45, 30, 15, 0];
  static const List<List<double>> _mc2ll = [
    [
      1.410526172116255e-8,
      8.98305509648872e-6,
      -1.9939833816331,
      200.9824383106796,
      -187.2403703815547,
      91.6087516669843,
      -23.38765649603339,
      2.57121317296198,
      -0.03801003308653,
      17337981.2
    ],
    [
      -7.435856389565537e-9,
      8.983055097726239e-6,
      -0.78625201886289,
      96.32687599759846,
      -1.85204757529826,
      -59.36935905485877,
      47.40033549296737,
      -16.50741931063887,
      2.28786674699375,
      10260144.86
    ],
    [
      -3.030883460898826e-8,
      8.98305509983578e-6,
      0.30071316287616,
      59.74293618442277,
      7.357984074871,
      -25.38371002664745,
      13.45380521110908,
      -3.29883767235584,
      0.32710905363475,
      6856817.37
    ],
    [
      -1.981981304930552e-8,
      8.983055099779535e-6,
      0.03278182852591,
      40.31678527705744,
      0.65659298677277,
      -4.44255534477492,
      0.85341911805263,
      0.12923347998204,
      -0.04625736007561,
      4482777.06
    ],
    [
      3.09191371068437e-9,
      8.983055096812155e-6,
      0.00006995724062,
      23.10934304144901,
      -0.00023663490511,
      -0.6321817810242,
      -0.00663494467273,
      0.03430082397953,
      -0.00466043876332,
      2555164.4
    ],
    [
      2.890871144776878e-9,
      8.983055095805407e-6,
      -0.00000003068298,
      7.47137025468032,
      -0.000000353937994,
      -0.02145144861037,
      -0.00001234426596,
      0.00010322952773,
      -0.00000323890364,
      826088.5
    ],
  ];
  static const List<List<double>> _ll2mc = [
    [
      -0.0015702102444,
      111320.7020616939,
      17337981.2,
      -10338987376042340,
      26112667856603880,
      -35149669176653700,
      26595700718403920,
      -10725012454188240,
      1800819912950474,
      82.5
    ],
    [
      0.0008277824516172526,
      111320.7020463578,
      647795574.6671607,
      -4082003173.641316,
      10774905663.51142,
      -15171875531.51559,
      12053065338.62167,
      -5124939663.577472,
      913311935.9512032,
      67.5
    ],
    [
      0.00337398766765,
      111320.7020202162,
      4481351.045890365,
      -23393751.19931662,
      79682215.47186455,
      -115964993.2797253,
      97236711.15602145,
      -43661946.33752821,
      8477230.501135234,
      52.5
    ],
    [
      0.00220636496208,
      111320.7020209128,
      51751.86112841131,
      3796837.749470245,
      992013.7397791013,
      -1221952.21711287,
      1340652.697009075,
      -620943.6990984312,
      144416.9293806241,
      37.5
    ],
    [
      -0.0003441963504368392,
      111320.7020576856,
      278.2353980772752,
      2485758.690035394,
      6070.750963243378,
      54821.18345352118,
      9540.606633304236,
      -2710.55326746645,
      1405.483844121726,
      22.5
    ],
    [
      -0.0003218135878613132,
      111320.7020701615,
      0.00369383431289,
      823725.6402795718,
      0.46104986909093,
      2351.343141331292,
      1.58060784298199,
      8.77738589078284,
      0.37238884252424,
      7.45
    ],
  ];

  static bool _isOutOfChina(double lat, double lng) {
    return lng < 72.004 || lng > 137.8347 || lat < 0.8293 || lat > 55.8271;
  }

  static double _transformLat(double x, double y) {
    double ret = -100.0 +
        2.0 * x +
        3.0 * y +
        0.2 * y * y +
        0.1 * x * y +
        0.2 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(y * _pi) + 40.0 * sin(y / 3.0 * _pi)) * 2.0 / 3.0;
    ret +=
        (160.0 * sin(y / 12.0 * _pi) + 320 * sin(y * _pi / 30.0)) * 2.0 / 3.0;
    return ret;
  }

  static double _transformLng(double x, double y) {
    double ret =
        300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(x.abs());
    ret += (20.0 * sin(6.0 * x * _pi) + 20.0 * sin(2.0 * x * _pi)) * 2.0 / 3.0;
    ret += (20.0 * sin(x * _pi) + 40.0 * sin(x / 3.0 * _pi)) * 2.0 / 3.0;
    ret +=
        (150.0 * sin(x / 12.0 * _pi) + 300.0 * sin(x / 30.0 * _pi)) * 2.0 / 3.0;
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

  static (double x, double y) bd09ToMercator(double lat, double lng) {
    final normalizedLng = _normalizeLongitude(lng);
    final normalizedLat = lat.clamp(-74.0, 74.0);
    final factors = _pickFactors(normalizedLat.abs(), _llBand, _ll2mc);
    return _convert(normalizedLng, normalizedLat, factors);
  }

  static (double lat, double lng) mercatorToBd09(double x, double y) {
    final factors = _pickFactors(y.abs(), _mcBand, _mc2ll);
    final (lng, lat) = _convert(x, y, factors);
    return (lat.clamp(-74.0, 74.0), _normalizeLongitude(lng));
  }

  static List<double> _pickFactors(
    double value,
    List<double> bands,
    List<List<double>> factorSets,
  ) {
    for (var index = 0; index < bands.length; index++) {
      if (value >= bands[index]) {
        return factorSets[index];
      }
    }
    return factorSets.last;
  }

  static (double x, double y) _convert(
    double x,
    double y,
    List<double> factors,
  ) {
    final normalizedY = y.abs() / factors[9];
    final convertedX = factors[0] + factors[1] * x.abs();
    final convertedY = factors[2] +
        factors[3] * normalizedY +
        factors[4] * normalizedY * normalizedY +
        factors[5] * normalizedY * normalizedY * normalizedY +
        factors[6] * normalizedY * normalizedY * normalizedY * normalizedY +
        factors[7] *
            normalizedY *
            normalizedY *
            normalizedY *
            normalizedY *
            normalizedY +
        factors[8] *
            normalizedY *
            normalizedY *
            normalizedY *
            normalizedY *
            normalizedY *
            normalizedY;

    return (
      x < 0 ? -convertedX : convertedX,
      y < 0 ? -convertedY : convertedY,
    );
  }

  static double _normalizeLongitude(double lng) {
    if (lng < -180 || lng > 180) {
      return lng - (lng / 360).truncateToDouble() * 360;
    }
    return lng;
  }
}
