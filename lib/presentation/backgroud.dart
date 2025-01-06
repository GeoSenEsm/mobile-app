import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:location/location.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/send_location_data_usecase.dart';
import 'package:survey_frontend/core/usecases/send_sensors_data_usecase.dart';
import 'package:survey_frontend/presentation/bindings/initial_bindings.dart';

Future<bool> sendSensorsData() async {
  try {
    var service = Get.find<SendSensorsDataUsecase>();
    final location = Get.find<Location>();
    location.enableBackgroundMode(enable: true);
    return await service.readAndSendSensorData();
  } catch (e) {
    Sentry.captureException(e);
    return false;
  }
}

Future<bool> readLocation() async {
 try {
    var service = Get.find<SendLocationDataUsecase>();
    final location = Get.find<Location>();
    location.enableBackgroundMode(enable: true);
    return await service.readAndSendLocationData();
  } catch (e) {
    Sentry.captureException(e);
    return false;
  }
}

void backgroundTask(String taskId) async {
  try {
    InitialBindings().dependencies();
    if (!userLoggedIn()) {
      return;
    }

    if (!Sentry.isEnabled) {
      await initSentry();
    }

    await sendSensorsData();
    await readLocation();
  } catch (e) {
    //for now let's ignore
  } finally {
    if (taskId.isNotEmpty) {
      BackgroundFetch.finish(taskId);
    }
  }
}

bool userLoggedIn() {
  return GetStorage().read('apiToken') != null;
}

Future<void> initSentry() async {
  if (kReleaseMode) {
    await dotenv.load(isOptional: true);
    final dsn = dotenv.env['SENTRY_DSN'];

    if (dsn == null){
      return;
    }

    await SentryFlutter.init((options) {
      options.dsn = dsn;
    });
  }
}