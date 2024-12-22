import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/sensor_data_history_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class SensorDataHistoryNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null &&
        previousRoute.settings.name == Routes.sensorDataHistory) {
      final controller = Get.find<SensorDataHistoryController>();
      controller.from.value = controller.dateFilters.value.from;
      controller.to.value = controller.dateFilters.value.to;
      controller.loadData();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == Routes.sensorDataHistory){
      final controller = Get.find<SensorDataHistoryController>();
      controller.loadData();
    }
  }
}
