import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/data/datasources/local/privacy_settings_repository.dart';
import 'package:survey_frontend/data/models/privacy_settings.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';

class PrivacySettingsController extends ControllerBase {
  final PrivacySettingsRepository _privacySettingsRepository;

  final RxBool enableTrackingLocation = false.obs;
  final Rx<TimeOfDay> timeFrom = const TimeOfDay(hour: 16, minute: 0).obs;
  final Rx<TimeOfDay> timeTo = const TimeOfDay(hour: 16, minute: 0).obs;

  PrivacySettingsController(this._privacySettingsRepository);

  void loadPrivacySettings() async {
    final privacySettings = await _privacySettingsRepository.read();
    timeFrom.value = privacySettings.allowLocationTrackingFrom;
    timeTo.value = privacySettings.allowLocationTrackingTo;
    enableTrackingLocation.value = privacySettings.allowLocationTracking;
  }

  void save() async {
    try {
      final privacySettings = PrivacySettings(
        allowLocationTracking: enableTrackingLocation.value,
        allowLocationTrackingFrom: timeFrom.value,
        allowLocationTrackingTo: timeTo.value,
      );
      await _privacySettingsRepository.save(privacySettings);
      Get.back();
    } catch (e) {
      handleSomethingWentWrong(e);
    }
  }

  setTimeFrom(TimeOfDay newFrom) {
    if (_isLater(newFrom, const TimeOfDay(hour: 23, minute: 58))) {
      return;
    }

    timeFrom.value = newFrom;
    if (_isLater(timeFrom.value, timeTo.value)) {
      if (_isLater(newFrom, const TimeOfDay(hour: 22, minute: 59))) {
        timeTo.value = const TimeOfDay(hour: 23, minute: 59);
      } else {
        timeTo.value = TimeOfDay(
            hour: timeFrom.value.hour + 1, minute: timeFrom.value.minute);
      }
    }
  }

  setTimeTo(TimeOfDay newTo) {
  if (!_isLater(newTo, const TimeOfDay(hour: 0, minute: 1))) {
    return;
  }

  timeTo.value = newTo;
  if (!_isLater(timeTo.value, timeFrom.value)) {
    if (!_isLater(newTo, const TimeOfDay(hour: 1, minute: 0))) {
      timeFrom.value = const TimeOfDay(hour: 0, minute: 1);
    } else {
      timeFrom.value = TimeOfDay(
          hour: timeTo.value.hour - 1, minute: timeTo.value.minute);
    }
  }
}


  bool _isLater(TimeOfDay x, TimeOfDay y) {
    return (60 * x.hour + x.minute) > (60 * y.hour + y.minute);
  }
}
