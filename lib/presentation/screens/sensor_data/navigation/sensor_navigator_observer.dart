import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SensorNavigatorObserver extends NavigatorObserver {

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route.settings.name == Routes.sensorDataScreen){
      Get.find<SensorDataController>().disconnect();
    }

    if (previousRoute != null && previousRoute.settings.name == Routes.sensorDataScreen){
      Get.find<SensorDataController>().startScanning();
    }
    super.didPop(route, previousRoute);
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (previousRoute != null && previousRoute.settings.name == Routes.sensorDataScreen){
      Get.find<SensorDataController>().disconnect();
    }

    if (route.settings.name == Routes.sensorDataScreen) {
      Get.find<SensorDataController>().startScanning();
    }
    super.didPush(route, previousRoute);
  }

}