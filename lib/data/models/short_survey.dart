import 'package:get/get.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SurveyShortInfo {
  final String name;
  final String id;
  DateTime startTime;
  DateTime finishTime;
  SurveyShortInfo(
      {required this.name,
      required this.id,
      required this.finishTime,
      required this.startTime});

  void setSurveyNotifications() {
    // TODO: nice if it will take a user to the survey immediately
    const timeBeforeFinish = 15;

    NotificationService.scheduleNotification(
        startTime.toLocal(),
        getSurveyNotificationID(id, startTime),
        AppLocalizations.of(Get.context!)!.surveyStartTitle,
        AppLocalizations.of(Get.context!)!.surveyStartBody,
        id);

    if (finishTime
        .subtract(const Duration(minutes: timeBeforeFinish))
        .isBefore(startTime)) {
      return;
    }
    NotificationService.scheduleNotification(
        finishTime
            .toLocal()
            .subtract(const Duration(minutes: timeBeforeFinish)),
        getSurveyNotificationID(id, finishTime),
        AppLocalizations.of(Get.context!)!.surveyFinishTitle,
        AppLocalizations.of(Get.context!)!.surveyFinishBody,
        id);
  }
}
