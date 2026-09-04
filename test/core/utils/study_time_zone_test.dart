import 'package:flutter_test/flutter_test.dart';
import 'package:survey_frontend/core/utils/study_time_zone.dart';
import 'package:timezone/data/latest.dart' as tzdata;

void main() {
  setUpAll(() {
    tzdata.initializeTimeZones();
  });

  group('StudyTimeZone', () {
    test('converts study wall clock to UTC for respondent timezone', () {
      final wallClock = DateTime.utc(2026, 8, 3, 13);

      final converted = StudyTimeZone.wallClockToUtc(wallClock, 'Europe/Warsaw');

      expect(converted, DateTime.utc(2026, 8, 3, 11));
    });

    test('falls back to UTC for unknown timezone ids', () {
      final wallClock = DateTime.utc(2026, 8, 3, 13);

      final converted = StudyTimeZone.wallClockToUtc(wallClock, 'Not/AZone');

      expect(converted, DateTime.utc(2026, 8, 3, 13));
    });

    test('formats local offset timestamp without milliseconds', () {
      final value = DateTime(2026, 8, 3, 13, 5, 9);

      final formatted = StudyTimeZone.withLocalOffsetIso8601(value);

      expect(formatted, matches(RegExp(r'^2026-08-03T13:05:09[+-]\d{2}:\d{2}$')));
    });
  });
}
