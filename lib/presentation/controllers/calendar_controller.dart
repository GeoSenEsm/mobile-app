import 'package:calendar_view/calendar_view.dart';
import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/usecases/calendar_event_usecase.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';
import 'package:survey_frontend/l10n/get_localizations.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/screens/calendar/widgets/event_details.dart';

class CalendarController extends ControllerBase {
  final eventController = EventController();
  final CalendarEventUsecase _calendarEventUsecase;
  final Rx<CalendarView> selectedView = CalendarView.day.obs;

  CalendarController(this._calendarEventUsecase);

  void loadEvents() async {
    try {
      final events = await _calendarEventUsecase.getAllSurveyCalendarEvents();
      final calendarEventDatas = events
          .map((e) => CalendarEventData(
              title: e.surveyName,
              date: e.from.toLocal(),
              startTime: e.from.toLocal(),
              endTime: e.to.toLocal(),
              event: e))
          .toList();
      eventController.addAll(calendarEventDatas);
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  void clear() {
    eventController.removeWhere((_) => true);
  }

  String getCalendarViewDisplay(CalendarView view) {
    return view == CalendarView.day
        ? getAppLocalizations().day
        : getAppLocalizations().week;
  }

  void onEventTap(SurveyCalendarEvent event) {
    Get.to(EventDetails(event: event));
  }
}

enum CalendarView { day, week }
