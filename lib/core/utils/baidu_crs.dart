import 'dart:math';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:survey_frontend/core/utils/coordinate_converter.dart';

class BaiduCrs extends Crs {
  static const double _extent = 20037726.37;
  static const double _transformScale = 0.5 / _extent;
  static const Projection _projection = _BaiduProjection();

  const BaiduCrs()
      : super(
          code: 'BD09MC',
          infinite: true,
          wrapLat: null,
          wrapLng: null,
        );

  @override
  Projection get projection => _projection;

  @override
  (double, double) transform(double x, double y, double scale) => (
        scale * (_transformScale * x + 0.5),
        scale * (-_transformScale * y + 0.5),
      );

  @override
  (double, double) untransform(double x, double y, double scale) => (
        (x / scale - 0.5) / _transformScale,
        (y / scale - 0.5) / -_transformScale,
      );

  @override
  (double, double) latLngToXY(LatLng latlng, double scale) {
    final (x, y) = projection.projectXY(latlng);
    return transform(x, y, scale);
  }

  @override
  LatLng pointToLatLng(Point point, double zoom) {
    final (x, y) = untransform(
      point.x.toDouble(),
      point.y.toDouble(),
      scale(zoom),
    );
    return projection.unprojectXY(x, y);
  }

  @override
  Bounds<double>? getProjectedBounds(double zoom) => null;
}

class _BaiduProjection extends Projection {
  const _BaiduProjection() : super(null);

  @override
  (double, double) projectXY(LatLng latlng) =>
      CoordinateConverter.bd09ToMercator(latlng.latitude, latlng.longitude);

  @override
  LatLng unprojectXY(double x, double y) {
    final (lat, lng) = CoordinateConverter.mercatorToBd09(x, y);
    return LatLng(lat, lng);
  }
}
