import 'dart:math';

import 'package:flutter_map/flutter_map.dart';

class BaiduTileProvider extends NetworkTileProvider {
  static const String _fallbackUrlTemplate =
      'https://gss{s}.bdstatic.com/8bo_dTSlRsgBo1vgoIiO_jowehsv/tile/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=1';

  BaiduTileProvider({super.headers, super.silenceExceptions});

  @override
  String getTileUrl(TileCoordinates coordinates, TileLayer options) {
    final zoom = (options.zoomOffset +
            (options.zoomReverse
                ? options.maxZoom - coordinates.z.toDouble()
                : coordinates.z.toDouble()))
        .round();

    final offsetX = zoom > 0 ? pow(2, zoom - 1).toInt() : 0;
    final baiduX = coordinates.x - offsetX;
    final baiduY = offsetX - 1 - coordinates.y;
    final template = options.urlTemplate ?? _fallbackUrlTemplate;
    final subdomain = options.subdomains.isEmpty
        ? ''
        : options.subdomains[
            (coordinates.x + coordinates.y) % options.subdomains.length];

    final replacements = <String, String>{
      'x': baiduX.toString(),
      'y': baiduY.toString(),
      'z': zoom.toString(),
      's': subdomain,
      'r': options.resolvedRetinaMode == RetinaMode.server ? '@2x' : '',
      'd': options.tileSize.toInt().toString(),
      ...options.additionalOptions,
    };

    return template.replaceAllMapped(
      TileProvider.templatePlaceholderElement,
      (match) {
        final value = replacements[match.group(1)!];
        if (value != null) return value;
        throw ArgumentError(
          'Missing value for placeholder: {${match.group(1)}}',
        );
      },
    );
  }
}
