import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/app_state.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/home_controller.dart';
import 'package:survey_frontend/presentation/static/routes.dart';

class HomeNavigatorObserver extends NavigatorObserver {
  @override
  void didPop(Route route, Route? previousRoute) {
    if (isHome(previousRoute)) {
      Get.find<HomeController>().triggerPullToRefresh();
      // Returning to home always ends the survey session, whether it was
      // submitted or the respondent backed out of it.
      final appState = Get.find<AppState>();
      appState.isSurveyActive = false;
      appState.currentSurveySensorData.clear();
      if (isSubmitSurvey()) {
        appState.justSubmitedSurvey = false;
        displayThanks();
      }
    }
  }

  bool isHome(Route? route) => route?.settings.name == Routes.home;
  bool isSubmitSurvey() => Get.find<AppState>().justSubmitedSurvey;

  void displayThanks() async {
    try {
      final databaseHelper = Get.find<DatabaseHelper>();
      final nextSurveyDuration = await databaseHelper.getTimeToNextSurvey();
      final localization = getAppLocalizations();
      final messageBuilder = StringBuffer();
      messageBuilder.write(localization.thanksForCompletingTheSurvey);
      messageBuilder.write(' ');
      if (nextSurveyDuration != null) {
        if (nextSurveyDuration.isNegative) {
          messageBuilder.write(localization.nextSurveyIsReadyToComplete);
        } else {
          final hours = nextSurveyDuration.inHours;
          final minutes = nextSurveyDuration.inMinutes.remainder(60);
          messageBuilder.write(localization.nextSurveyWillAppearIn(
              '${hours > 0 ? '$hours h ' : ''}${minutes > 0 ? '$minutes min' : ''}'
                  .trim()));
        }
      }

      await showDialog(
        context: Get.context!,
        builder: (context) {
          return AlertDialog(
            title: const Text(''),
            content: Text(messageBuilder.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(localization.ok),
              )
            ],
          );
        },
      );
    } catch (e) {
      Sentry.captureException(e);
    }
  }
}
