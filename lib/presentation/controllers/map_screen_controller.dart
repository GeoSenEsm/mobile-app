import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/date_filters.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/screens/date_filters/date_filters_screen.dart';
import 'package:survey_frontend/presentation/screens/map/location_details_screen.dart';

class MapScreenController extends ControllerBase {
  final String mapUrlTemplate =
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
  final DateFilters filters = DateFilters();
  final Rx<DateTime?> from = Rx<DateTime?>(null);
  final Rx<DateTime?> to = Rx<DateTime?>(null);
  final DatabaseHelper _databaseHelper;
  final MapController mapController = MapController();
  final RxList<LocationModel> locations = RxList.empty();

  MapScreenController(this._databaseHelper);

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

    final points =
        locations.map((e) => LatLng(e.latitude, e.longitude)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    final center = bounds.center;
    final zoom = _calculateZoom(bounds);
    mapController.move(center, zoom);
  }

  Future<void> _centerToCurrentPosition() async {
    final currentPosition = await Geolocator.getCurrentPosition();
    if (currentPosition != null) {
      mapController.move(
          LatLng(currentPosition.latitude, currentPosition.longitude), 14);
    }
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
