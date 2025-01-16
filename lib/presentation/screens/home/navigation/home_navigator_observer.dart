import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/home_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class HomeNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    if (previousRoute != null && previousRoute.settings.name == Routes.home) {
      Get.find<HomeController>().triggerPullToRefresh();
    }
  }
}
