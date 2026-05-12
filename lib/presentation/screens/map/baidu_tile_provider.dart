import 'dart:math' as math;

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

const int baiduMaxZoom = 18;

const List<double> _baiduLlBand = [75, 60, 45, 30, 15, 0];
const List<double> _baiduMcBand = [
  12890594.86,
  8362377.87,
  5591021,
  3481989.83,
  1678043.12,
  0,
];
const List<List<double>> _baiduLlToMc = [
  [-0.0015702102444, 111320.7020616939, 1704480524535203, -10338987376042340, 26112667856603880, -35149669176653700, 26595700718403920, -10725012454188240, 1800819912950474, 82.5],
  [0.0008277824516172526, 111320.7020463578, 647795574.6671607, -4082003173.641316, 10774905663.51142, -15171875531.51559, 12053065338.62167, -5124939663.577472, 913311935.9512032, 67.5],
  [0.00337398766765, 111320.7020202162, 4481351.045890365, -23393751.19931662, 79682215.47186455, -115964993.2797253, 97236711.15602145, -43661946.33752821, 8477230.501135234, 52.5],
  [0.00220636496208, 111320.7020209128, 51751.86112841131, 3796837.749470245, 992013.7397791013, -1221952.21711287, 1340652.697009075, -620943.6990984312, 144416.9293806241, 37.5],
  [-0.0003441963504368392, 111320.7020576856, 278.2353980772752, 2485758.690035394, 6070.750963243378, 54821.18345352118, 9540.606633304236, -2710.55326746645, 1405.483844121726, 22.5],
  [-0.0003218135878613132, 111320.7020701615, 0.00369383431289, 823725.6402795718, 0.46104986909093, 2351.343141331292, 1.58060784298199, 8.77738589078284, 0.37238884252424, 7.45],
];
const List<List<double>> _baiduMcToLl = [
  [1.410526172116255e-8, 8.98305509648872e-6, -1.9939833816331, 200.9824383106796, -187.2403703815547, 91.6087516669843, -23.38765649603339, 2.57121317296198, -0.03801003308653, 17337981.2],
  [-7.435856389565537e-9, 8.983055097726239e-6, -0.78625201886289, 96.32687599759846, -1.85204757529826, -59.36935905485877, 47.40033549296737, -16.50741931063887, 2.28786674699375, 10260144.86],
  [-3.030883460898826e-8, 8.98305509983578e-6, 0.30071316287616, 59.74293618442277, 7.357984074871, -25.38371002664745, 13.45380521110908, -3.29883767235584, 0.32710905363475, 6856817.37],
  [-1.981981304930552e-8, 8.983055099779535e-6, 0.03278182852591, 40.31678527705744, 0.65659298677277, -4.44255534477492, 0.85341911805263, 0.12923347998204, -0.04625736007561, 4482777.06],
  [3.09191371068437e-9, 8.983055096812155e-6, 0.00006995724062, 23.10934304144901, -0.00023663490511, -0.6321817810242, -0.00663494467273, 0.03430082397953, -0.00466043876332, 2555164.4],
  [2.890871144776878e-9, 8.983055095805407e-6, -0.00000003068298, 7.47137025468032, -0.00000353937994, -0.02145144861037, -0.00001234426596, 0.00010322952773, -0.00000323890364, 826088.5],
];

typedef BaiduTileCoordinates = ({int x, int y});

class BaiduTileCoordinateConverter {
  static BaiduTileCoordinates fromSlippy({
    required int x,
    required int y,
    required int zoom,
  }) {
    return (
      x: x,
      y: -y - 1,
    );
  }

  static String formatBaiduTileValue(int value) {
    return value.toString();
  }
}

class BaiduCrs extends Crs {
  const BaiduCrs()
      : super(
          projection: const BaiduProjection(),
          transformation: const Transformation(1, 0, -1, 0),
          infinite: true,
        );

  @override
  double scale(double zoom) => math.pow(2, zoom - baiduMaxZoom).toDouble();

  @override
  double zoom(double scale) => math.log(scale) / math.ln2 + baiduMaxZoom;
}

class BaiduProjection extends Projection {
  const BaiduProjection();

  @override
  Bounds<double> get bounds => Bounds<double>(
        const CustomPoint<double>(-20037726.37, -12474104.17),
        const CustomPoint<double>(20037726.37, 12474104.17),
      );

  @override
  CustomPoint<double> project(LatLng latlng) {
    final point = _baiduLatLngToMercator(latlng.latitude, latlng.longitude);
    return CustomPoint<double>(point.x, point.y);
  }

  @override
  LatLng unproject(CustomPoint<double> point) {
    final latLng = _baiduMercatorToLatLng(point.x, point.y);
    return LatLng(latLng.latitude, latLng.longitude);
  }
}

({double x, double y}) _baiduLatLngToMercator(
  double latitude,
  double longitude,
) {
  final lat = latitude.clamp(-74.0, 74.0).toDouble();
  final lon = _normalizeLongitude(longitude);
  final index = _baiduLlBand.indexWhere((band) => lat >= band);
  final factor = index == -1 ? _baiduLlToMc.last : _baiduLlToMc[index];
  return _baiduConvertor(lon, lat, factor);
}

({double latitude, double longitude}) _baiduMercatorToLatLng(double x, double y) {
  final absY = y.abs();
  final index = _baiduMcBand.indexWhere((band) => absY >= band);
  final factor = index == -1 ? _baiduMcToLl.last : _baiduMcToLl[index];
  final point = _baiduConvertor(x, y, factor);
  return (latitude: point.y, longitude: point.x);
}

({double x, double y}) _baiduConvertor(
  double x,
  double y,
  List<double> factors,
) {
  final xTemp = factors[0] + factors[1] * x.abs();
  final cC = y.abs() / factors[9];
  final yTemp = (factors[2] +
      factors[3] * cC +
      factors[4] * cC * cC +
      factors[5] * math.pow(cC, 3) +
      factors[6] * math.pow(cC, 4) +
      factors[7] * math.pow(cC, 5) +
      factors[8] * math.pow(cC, 6))
      .toDouble();

  return (
    x: xTemp * (x < 0 ? -1 : 1),
    y: yTemp * (y < 0 ? -1 : 1),
  );
}

double _normalizeLongitude(double longitude) {
  var normalized = longitude;
  while (normalized > 180) {
    normalized -= 360;
  }
  while (normalized < -180) {
    normalized += 360;
  }
  return normalized;
}

class BaiduTileProvider extends NetworkTileProvider {
  const BaiduTileProvider();

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final zoom = coordinates.z.toInt();
    final converted = BaiduTileCoordinateConverter.fromSlippy(
      x: coordinates.x,
      y: coordinates.y,
      zoom: zoom,
    );

    var url = options.urlTemplate!;
    final subdomains = options.subdomains;
    if (subdomains.isNotEmpty) {
      final index = (converted.x + converted.y).abs() % subdomains.length;
      url = url.replaceAll('{s}', subdomains[index]);
    }

    return url
        .replaceAll(
          '{x}',
          BaiduTileCoordinateConverter.formatBaiduTileValue(converted.x),
        )
        .replaceAll(
          '{y}',
          BaiduTileCoordinateConverter.formatBaiduTileValue(converted.y),
        )
        .replaceAll('{z}', zoom.toString());
  }
}

