import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/survey_calendar_event.dart';

abstract class CalendarEventUsecase {
  Future<List<SurveyCalendarEvent>> getAllSurveyCalendarEvents();
}

class CalendarEventUsecaseImpl extends CalendarEventUsecase {
  final DatabaseHelper _databaseHelper;

  CalendarEventUsecaseImpl(this._databaseHelper);

  @override
  Future<List<SurveyCalendarEvent>> getAllSurveyCalendarEvents() async {
    return await _databaseHelper.getCalendarEvents();
  }
}
