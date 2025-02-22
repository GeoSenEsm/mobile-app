import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/location_model.dart';
import 'package:survey_frontend/domain/external_services/location_service.dart';
import 'package:survey_frontend/domain/models/localization_data.dart';

abstract class SendLocationDataUsecase {
  Future<bool> readAndSendLocationData();
  Future<bool> sendLocationData(LocationModel? location);
  Future<LocalizationData?> getCurrentLocation();
}

class SendLocationDataUsecaseImpl implements SendLocationDataUsecase {
  final DatabaseHelper _databaseHelper;
  final LocalizationService _locationService;
  final GetStorage _storage;

  SendLocationDataUsecaseImpl(
      this._databaseHelper, this._locationService, this._storage);

  @override
  Future<bool> readAndSendLocationData() async {
    final localizationData = await getCurrentLocation();
    final model = localizationData == null
        ? null
        : LocationModel(
            dateTime: DateTime.parse(localizationData.dateTime),
            longitude: localizationData.longitude,
            latitude: localizationData.latitude,
            sentToServer: false);
    return await sendLocationData(model);
  }

  @override
  Future<bool> sendLocationData(LocationModel? location) async {
    try {
      if (location != null) {
        await _databaseHelper.addLocation(location);
      }

      final allToSend = await _databaseHelper.getAllLocationsToSend();
      final submitResult = await _locationService.submitLocations(allToSend);

      if (submitResult.statusCode == 201) {
        await _databaseHelper.markAllSendableLocationsSentToServer();
      }

      return true;
    } catch (e) {
      Sentry.captureException(e);
      return false;
    }
  }

  @override
  Future<LocalizationData?> getCurrentLocation() async {
    try {
      if (!(_storage.read('enableTrackingLocation') ?? true)) {
        return null;
      }

      final timeFrom = _storage.read<TimeOfDay>('allowLocationTrackingFrom') ??
          const TimeOfDay(hour: 8, minute: 0);
      final timeTo = _storage.read<TimeOfDay>('allowLocationTrackingTo') ??
          const TimeOfDay(hour: 22, minute: 0);
      final now = DateTime.now();
      final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

      if (!_isBetween(nowTime, timeFrom, timeTo)) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      Position currentLocation = await Geolocator.getCurrentPosition();
      final locationData = LocalizationData(
          dateTime: now.toUtc().toIso8601String(),
          latitude: double.parse(currentLocation.latitude.toStringAsFixed(6)),
          longitude:
              double.parse(currentLocation.longitude.toStringAsFixed(6)));

      return locationData;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    }
  }

  bool _isBetween(TimeOfDay time, TimeOfDay start, TimeOfDay end) {
    final startInMinutes = start.hour * 60 + start.minute;
    final endInMinutes = end.hour * 60 + end.minute;
    final timeInMinutes = time.hour * 60 + time.minute;

    if (startInMinutes < endInMinutes) {
      return timeInMinutes >= startInMinutes && timeInMinutes <= endInMinutes;
    } else {
      return timeInMinutes >= startInMinutes || timeInMinutes <= endInMinutes;
    }
  }
}
