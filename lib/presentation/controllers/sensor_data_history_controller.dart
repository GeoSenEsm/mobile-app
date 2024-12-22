import 'package:get/get.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:survey_frontend/core/models/date_filters.dart';
import 'package:survey_frontend/data/datasources/local/database_service.dart';
import 'package:survey_frontend/data/models/sensor_data_model.dart';
import 'package:survey_frontend/presentation/controllers/controller_base.dart';
import 'package:survey_frontend/presentation/screens/date_filters/date_filters_screen.dart';

class SensorDataHistoryController extends ControllerBase {
  final Rx<DateFilters> dateFilters = DateFilters().obs;
  final Rx<DateTime?> from = Rx<DateTime?>(null);
  final Rx<DateTime?> to = Rx<DateTime?>(null);
  final RxList<SensorDataModel> entries = RxList.empty();
  final DatabaseHelper _databaseHelper;

  SensorDataHistoryController(this._databaseHelper);

  void openFilters() {
    Get.to(DateFiltersScreen(originalFilters: dateFilters.value));
  }

  void loadData() async {
    try {
      entries.clear();
      final actualFrom = _getActualFromUtc();
      final actualTo = _getActualToUtc();
      final results = await _databaseHelper.getAllSensorDataFilterByDate(actualFrom, actualTo);
      entries.addAll(results);
    } catch (e) {
      Sentry.captureException(e);
    }
  }

  DateTime _getActualFromUtc() {
    if (from.value != null) {
      return from.value!;
    }

    final today = DateTime.now();
    final daysToSubstract = today.weekday - DateTime.monday;
    final startOfWeek = today.subtract(Duration(days: daysToSubstract));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day)
        .toUtc();
  }

  DateTime _getActualToUtc() {
    if (from.value != null) {
      return from.value!;
    }

    final today = DateTime.now();
    final daysToSubstract = DateTime.sunday - today.weekday;
    final startOfWeek = today.add(Duration(days: daysToSubstract));
    return DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 23, 59)
        .toUtc();
  }
}
