import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:survey_frontend/presentation/controllers/calendar_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class CalendarNavigatorObserver extends NavigatorObserver {
@override
  void didPush(Route route, Route? previousRoute) {
    if (route.settings.name == Routes.calendar){
      Get.find<CalendarController>().loadEvents();
    }
    super.didPush(route, previousRoute);
  }
}