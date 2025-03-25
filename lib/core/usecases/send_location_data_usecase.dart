import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/datasources/local/privacy_settings_repository.dart';
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
  final PrivacySettingsRepository _privacySettingsRepository;

  SendLocationDataUsecaseImpl(this._databaseHelper, this._locationService,
      this._privacySettingsRepository);

  @override
  Future<bool> readAndSendLocationData() async {
    final localizationData = await getCurrentLocation();
    final model = localizationData == null
        ? null
        : LocationModel(
            dateTime: DateTime.parse(localizationData.dateTime),
            longitude: localizationData.longitude,
            latitude: localizationData.latitude,
            sentToServer: false,
            accuracyMeters: localizationData.accuracyMeters);
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
      final privacySettings = await _privacySettingsRepository.read();
      if (!privacySettings.allowLocationTracking) {
        return null;
      }

      final now = DateTime.now();
      final nowTime = TimeOfDay(hour: now.hour, minute: now.minute);

      if (!_isBetween(nowTime, privacySettings.allowLocationTrackingFrom,
          privacySettings.allowLocationTrackingTo)) {
        return null;
      }
      if (!await Geolocator.isLocationServiceEnabled()) {
        return null;
      }
      Position currentLocation = await Geolocator.getCurrentPosition();
      final double? accuracy = currentLocation.accuracy >= 0 && currentLocation.accuracy <  99999 ?
          double.parse(currentLocation.accuracy.toStringAsFixed(2)) : null;
      final locationData = LocalizationData(
          dateTime: now.toUtc().toIso8601String(),
          latitude: double.parse(currentLocation.latitude.toStringAsFixed(6)),
          longitude:
              double.parse(currentLocation.longitude.toStringAsFixed(6)),
          accuracyMeters: accuracy);

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
