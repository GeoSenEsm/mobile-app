import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/map_screen_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class MapNavigatorObserver extends NavigatorObserver{
 @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null &&
        previousRoute.settings.name == Routes.map
        && route.settings.name == "/DateFiltersScreen") {
      final controller = Get.find<MapScreenController>();
      controller.from.value = controller.filters.from;
      controller.to.value = controller.filters.to;
      controller.loadData();
    }
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == Routes.map){
      final controller = Get.find<MapScreenController>();
      controller.loadData();
    }
  }
}