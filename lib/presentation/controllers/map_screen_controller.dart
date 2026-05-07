import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/date_filters.dart';
import 'package:survey_frontend/core/models/map_provider.dart';
import 'package:survey_frontend/core/utils/baidu_crs.dart';
import 'package:survey_frontend/core/utils/coordinate_converter.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/screens/date_filters/date_filters_screen.dart';
import 'package:survey_frontend/presentation/screens/map/location_details_screen.dart';

class MapScreenController extends ControllerBase {
  static const String _storageKey = 'map_provider';
  static const LatLng _warsawCenter = LatLng(52.2297, 21.0122);
  static const LatLng _beijingCenter = LatLng(39.9042, 116.4074);

  final DateFilters filters = DateFilters();
  final Rx<DateTime?> from = Rx<DateTime?>(null);
  final Rx<DateTime?> to = Rx<DateTime?>(null);
  final DatabaseHelper _databaseHelper;
  final MapController mapController = MapController();
  final RxList<LocationModel> locations = RxList.empty();
  late final Rx<MapProvider> mapProvider;

  MapScreenController(this._databaseHelper) {
    mapProvider = Rx<MapProvider>(_loadProvider());
  }

  MapProvider _defaultProvider() {
    const appType =
        String.fromEnvironment('APP_TYPE', defaultValue: 'geosenesm');
    return appType == 'geosenesm'
        ? MapProvider.openStreetMap
        : MapProvider.baidu;
  }

  MapProvider _loadProvider() {
    final stored = GetStorage().read<String>(_storageKey);
    if (stored == 'baidu') return MapProvider.baidu;
    if (stored == 'openStreetMap') return MapProvider.openStreetMap;
    return _defaultProvider();
  }

  void setMapProvider(MapProvider provider) {
    mapProvider.value = provider;
    GetStorage().write(
        _storageKey, provider == MapProvider.baidu ? 'baidu' : 'openStreetMap');
  }

  String get tileUrlTemplate {
    if (mapProvider.value == MapProvider.baidu) {
      return 'https://gss{s}.bdstatic.com/8bo_dTSlRsgBo1vgoIiO_jowehsv/tile/?qt=tile&x={x}&y={y}&z={z}&styles=pl&scaler=1';
    }
    return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  }

  LatLng get initialCenter => _convertLatLng(
      mapProvider.value == MapProvider.baidu ? _beijingCenter : _warsawCenter);

  double get initialZoom => 13.0;

  Crs get mapCrs => mapProvider.value == MapProvider.baidu
      ? const BaiduCrs()
      : const Epsg3857();

  List<String> get tileSubdomains {
    if (mapProvider.value == MapProvider.baidu) {
      return ['0', '1', '2', '3'];
    }
    return const [];
  }

  LatLng convertCoordinate(double lat, double lng) {
    if (mapProvider.value == MapProvider.baidu) {
      final (bdLat, bdLng) = CoordinateConverter.wgs84ToBd09(lat, lng);
      return LatLng(bdLat, bdLng);
    }
    return LatLng(lat, lng);
  }

  LatLng _convertLatLng(LatLng point) =>
      convertCoordinate(point.latitude, point.longitude);

  void loadData() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      locations.clear();
      final actualFrom = _getActualFromUtc();
      final actualTo = _getActualToUtc();
      final results =
          await _databaseHelper.getAllLocationsBetween(actualFrom, actualTo);
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _setBounds(results);
        locations.addAll(results);
      });
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  DateTime _getActualFromUtc() {
    if (from.value != null) {
      return from.value!.toUtc();
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 0, 0).toUtc();
  }

  DateTime _getActualToUtc() {
    if (to.value != null) {
      return to.value!.toUtc();
    }

    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59).toUtc();
  }

  Future<void> _setBounds(List<LocationModel> locations) async {
    if (locations.isEmpty) {
      mapController.move(initialCenter, initialZoom);
      return;
    }

    final points = locations
        .map((location) =>
            convertCoordinate(location.latitude, location.longitude))
        .toList();
    final bounds = LatLngBounds.fromPoints(points);
    final center = bounds.center;
    final zoom = _calculateZoom(bounds);
    mapController.move(center, zoom);
  }

  void openFilters() {
    Get.to(DateFiltersScreen(originalFilters: filters));
  }

  double _calculateZoom(LatLngBounds bounds) {
    const double minZoom = 3;
    const double maxZoom = 18;
    final latDiff = bounds.north - bounds.south;
    final lngDiff = bounds.east - bounds.west;
    final zoom = 16 - (latDiff + lngDiff);
    return zoom.clamp(minZoom, maxZoom);
  }

  void openDetails(LocationModel model) {
    Get.to(LocationDetailsScreen(model: model));
  }
}
