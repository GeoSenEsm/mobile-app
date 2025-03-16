import 'dart:math';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/survey_notification_id_usecase.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/short_survey.dart';
import 'package:survey_frontend/domain/local_services/notification_service.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';

abstract class SurveyNotificationUseCase {
  Future<void> scheduleSurveysNotifications();
}

class SurveyNotificationUseCaseImpl implements SurveyNotificationUseCase {
  final DatabaseHelper _databaseHelper;
  final SurveyNotificationIdUsecase _surveyNotificationIdUsecase;

  SurveyNotificationUseCaseImpl(this._databaseHelper, this._surveyNotificationIdUsecase);

  @override
  Future<void> scheduleSurveysNotifications() async {
    NotificationService.cancelAllNotifications();
    List<SurveyShortInfo> futureAndOngoingSurveys =
        await _databaseHelper.getFutureAndOngoingSurveys();
    futureAndOngoingSurveys.sort((a, b) => a.startTime.compareTo(b.startTime));
    final first25TimeSlots = futureAndOngoingSurveys.sublist(
        0, min(25, futureAndOngoingSurveys.length));
    for (final element in first25TimeSlots) {
      await _setSurveyNotifications(element);
    }
  }

  Future<void> _setSurveyNotifications(SurveyShortInfo survey) async {
    try {
      const timeBeforeFinish = 15;
      final now = DateTime.now();
      final startTimeLocal = survey.startTime.toLocal();

      final startId = _surveyNotificationIdUsecase.getStartNotificationId(survey);

      if (startTimeLocal.isAfter(now)) {
        await NotificationService.scheduleNotification(
            startTimeLocal,
            startId,
            getAppLocalizations().surveyStartTitle,
            getAppLocalizations().surveyStartBody,
            survey.id);
      }

      final finishNotificationTimeLocal = survey.finishTime
          .toLocal()
          .subtract(const Duration(minutes: timeBeforeFinish));

      final finishId = _surveyNotificationIdUsecase.getFinishNotificationId(survey);

      if (finishNotificationTimeLocal.isAfter(survey.startTime) &&
          finishNotificationTimeLocal.isAfter(now)) {
        await NotificationService.scheduleNotification(
            finishNotificationTimeLocal,
            finishId,
            getAppLocalizations().surveyFinishTitle,
            getAppLocalizations().surveyFinishBody,
            survey.id);
      }
    } catch (e) {
      Sentry.captureException(e);
    }
  }
}
