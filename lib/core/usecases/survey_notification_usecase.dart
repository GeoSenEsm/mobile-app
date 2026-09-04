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

  SurveyNotificationUseCaseImpl(
      this._databaseHelper, this._surveyNotificationIdUsecase);

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
      final now = DateTime.now();
      final startTimeLocal = survey.startTime.toLocal();
      final finishTimeLocal = survey.finishTime.toLocal();
      final notifications =
          await _databaseHelper.getSurveyNotifications(survey.id);
      final l10n = getAppLocalizations();

      for (var i = 0; i < notifications.length; i++) {
        final rule = notifications[i];
        final isEnd = rule.relativeTo == 'end';
        final anchor = isEnd ? finishTimeLocal : startTimeLocal;
        final fireTime = anchor.subtract(Duration(minutes: rule.minutesBefore));

        if (!fireTime.isAfter(now)) {
          continue;
        }
        if (isEnd && !fireTime.isAfter(startTimeLocal)) {
          continue;
        }

        await NotificationService.scheduleNotification(
            fireTime,
            _surveyNotificationIdUsecase.getNotificationId(survey, i),
            isEnd ? l10n.surveyFinishTitle : l10n.surveyStartTitle,
            isEnd ? l10n.surveyFinishBody : l10n.surveyStartBody,
            survey.id);
      }
    } catch (e) {
      Sentry.captureException(e);
    }
  }
}
