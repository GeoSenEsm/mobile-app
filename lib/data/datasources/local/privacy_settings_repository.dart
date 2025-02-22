import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:survey_frontend/data/models/privacy_settings.dart';

abstract class PrivacySettingsRepository{
  Future<PrivacySettings> read();
  Future<void> save(PrivacySettings privacySettings);
}

class PrivacySettingsRepositoryImpl extends PrivacySettingsRepository{
  final GetStorage _storage;

  PrivacySettingsRepositoryImpl(this._storage);
  
  @override
  Future<PrivacySettings> read() {
    final json = _storage.read('privacySettings');
    if(json == null){
      return Future.value(PrivacySettings(
        allowLocationTracking: true,
        allowLocationTrackingFrom: const TimeOfDay(hour: 8, minute: 0),
        allowLocationTrackingTo: const TimeOfDay(hour: 20, minute: 0)
      ));
    }
    return Future.value(PrivacySettings.fromJson(json));
  }
  
  @override
  Future<void> save(PrivacySettings privacySettings) async {
    await _storage.write('privacySettings', privacySettings.toJson());
  }
}