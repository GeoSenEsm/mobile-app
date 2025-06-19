import 'dart:async';

import 'package:background_fetch/background_fetch.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/presentation/bindings/initial_bindings.dart';

Future<bool> sendSensorsData() async {
  try {
    var service = Get.find<SendSensorsDataUsecase>();
    return await service.readAndSendSensorData(const Duration(seconds: 10));
  } catch (e) {
    Sentry.captureException(e);
    return false;
  }
}

Future<bool> readLocation() async {
  try {
    var service = Get.find<SendLocationDataUsecase>();
    if (!await Permission.locationAlways.status.isGranted) {
      final connecivity = Connectivity();
      final results = await connecivity.checkConnectivity();
      if (!results.contains(ConnectivityResult.mobile) && !results.contains(ConnectivityResult.ethernet)
       && !results.contains(ConnectivityResult.wifi)){
        return false;
       }
      return service.sendLocationData(null);
    }

    return await service.readAndSendLocationData();
  } catch (e) {
    Sentry.captureException(e);
    return false;
  }
}

void backgroundTask(String taskId) async {
  try {
    await _bgCore().timeout(const Duration(seconds: 25), onTimeout: (){
      throw TimeoutException("Bg task timeout");
    });
  } on TimeoutException catch (_){
    Sentry.captureMessage("Background task timeout");
    return;
  } catch (e) {
    Sentry.captureException(e);
  } finally {
    if (taskId.isNotEmpty) {
      BackgroundFetch.finish(taskId);
    }
  }
}

Future _bgCore() async {
  InitialBindings().dependencies();
    if (!userLoggedIn()) {
      return;
    }

    if (Sentry.isEnabled) {
      await initSentry();
    }
    await readLocation();
    await sendSensorsData();
}

bool userLoggedIn() {
  return GetStorage().read('apiToken') != null;
}

Future<void> initSentry() async {
  if (kReleaseMode) {
    await dotenv.load(isOptional: true);
    final dsn = dotenv.env['SENTRY_DSN'];

    if (dsn == null) {
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = dsn;
    });
  }
}
