import 'package:flutter_map/flutter_map.dart';

typedef BaiduTileCoordinates = ({int x, int y});

class BaiduTileCoordinateConverter {
  static BaiduTileCoordinates fromSlippy({
    required int x,
    required int y,
    required int zoom,
  }) {
    if (zoom <= 0) {
      return (x: x, y: y);
    }

    final offset = 1 << (zoom - 1);
    return (
      x: x - offset,
      y: offset - y - 1,
    );
  }

  static String formatBaiduTileValue(int value) {
    if (value < 0) {
      return 'M${value.abs()}';
    }

    return value.toString();
  }
}

class BaiduTileProvider extends NetworkTileProvider {
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
      final index = (coordinates.x + coordinates.y).abs() % subdomains.length;
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
