import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:latlong2/latlong.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/date_filters.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/screens/date_filters/date_filters_screen.dart';
import 'package:survey_frontend/presentation/screens/map/map_coordinate_converter.dart';
import 'package:survey_frontend/presentation/screens/map/map_provider_type.dart';
import 'package:survey_frontend/presentation/screens/map/location_details_screen.dart';

class MapScreenController extends ControllerBase {
  final DateFilters filters = DateFilters();
  final Rx<DateTime?> from = Rx<DateTime?>(null);
  final Rx<DateTime?> to = Rx<DateTime?>(null);
  final DatabaseHelper _databaseHelper;
  final GetStorage _storage;
  final MapController mapController = MapController();
  final RxList<LocationModel> locations = RxList.empty();
  final Rx<MapProviderType> selectedMapProvider = MapProviderType.google.obs;

  MapScreenController(this._databaseHelper, this._storage) {
    _loadSelectedMapProvider();
  }

  String get mapUrlTemplate => selectedMapProvider.value.tileUrlTemplate;

  List<String> get mapSubdomains => selectedMapProvider.value.subdomains;

  LatLng get initialCenter => mapPointForCoordinates(52.2297, 21.0122);

  LatLng mapPointForLocation(LocationModel model) {
    return mapPointForCoordinates(model.latitude, model.longitude);
  }

  LatLng mapPointForCoordinates(double latitude, double longitude) {
    return MapCoordinateConverter.wgs84ToProvider(
      LatLng(latitude, longitude),
      selectedMapProvider.value,
    );
  }

  Future<void> setMapProvider(MapProviderType provider) async {
    if (provider == selectedMapProvider.value) {
      return;
    }

    selectedMapProvider.value = provider;
    await _storage.write(selectedMapProviderStorageKey, provider.storageValue);

    if (locations.isEmpty) {
      await _centerToCurrentPosition();
      return;
    }

    await _setBounds(locations.toList(growable: false));
  }

  void _loadSelectedMapProvider() {
    final storedValue = _storage.read<String>(selectedMapProviderStorageKey);
    selectedMapProvider.value = mapProviderTypeFromStorage(storedValue);
  }

  void loadData() async {
    try {
      //TODO: can this be done cleaner?
      //it looks very dirty to me, but so far I have not found a better solution
      //if not deleayed, the map sometimes throws some exception, because I try to add pins, when it's not ready yet
      //this small delay seems to do the trick
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
      await _centerToCurrentPosition();
      return;
    }

    final points = locations.map(mapPointForLocation).toList();
    final bounds = LatLngBounds.fromPoints(points);
    final center = bounds.center;
    final zoom = _calculateZoom(bounds);
    mapController.move(center, zoom);
  }

  Future<void> _centerToCurrentPosition() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    mapController.move(
      mapPointForCoordinates(
        currentPosition.latitude,
        currentPosition.longitude,
      ),
      14,
    );
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
