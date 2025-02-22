import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

Future<void> buildLocationDenyDialog() async {
  return showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: Text(getAppLocalizations().locationPermissionDenied),
        content: Text(getAppLocalizations().locationPermissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(getAppLocalizations().close),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              var location = Location();
              location.enableBackgroundMode();
            },
            child: Text(getAppLocalizations().openSettings),
          )
        ],
      );
    },
  );
}

Future<void> buildLocationAlwaysDenyDialog() async {
  return showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: Text(getAppLocalizations().locationBackgroundPermissionDenied),
        content: Text(getAppLocalizations().locationBackgroundPermissionDeniedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(getAppLocalizations().close),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              AppSettings.openAppSettings(type: AppSettingsType.location);
            },
            child: Text(getAppLocalizations().openSettings),
          )
        ],
      );
    },
  );
}

Future<void> buildManyDenyDialog() async {
  return showDialog(
    context: Get.context!,
    builder: (context) {
      return AlertDialog(
        title: Text(getAppLocalizations().multiplePermissionsDenied),
        content: Text(getAppLocalizations().multiplePermissionsDeniedMessage),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(getAppLocalizations().close),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await Geolocator.openAppSettings();
            },
            child: Text(getAppLocalizations().openSettings),
          )
        ],
      );
    },
  );
}
