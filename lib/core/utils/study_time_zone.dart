import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get_storage/get_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:timezone/timezone.dart' as tz;

/// Study schedule slots arrive with a +00:00 / Z offset whose clock face is
/// the intended wall time (not a real UTC instant). Convert that face into
/// a real UTC instant in [timeZoneId], then optionally to device-local.
class StudyTimeZone {
  static const storageKey = 'respondentTimeZone';
  static const defaultId = 'UTC';

  /// Detects the device's current IANA timezone and caches it under
  /// [storageKey]. Returns null (and leaves whatever was previously cached
  /// untouched) if detection fails — a known failure on some OEM ROMs/
  /// emulators — rather than ever writing a synthetic value. Never throws.
  static Future<String?> detectAndCache(GetStorage storage) async {
    try {
      final timeZone = await FlutterTimezone.getLocalTimezone();
      storage.write(storageKey, timeZone);
      return timeZone;
    } catch (e) {
      Sentry.captureException(e);
      return null;
    }
  }

  /// Interprets [wallClockLabeledAsUtc]'s Y-M-D h:m:s as wall clock in
  /// [timeZoneId] and returns the corresponding UTC [DateTime].
  static DateTime wallClockToUtc(
      DateTime wallClockLabeledAsUtc, String timeZoneId) {
    final location = tz.getLocation(_safeZoneId(timeZoneId));
    final local = tz.TZDateTime(
      location,
      wallClockLabeledAsUtc.year,
      wallClockLabeledAsUtc.month,
      wallClockLabeledAsUtc.day,
      wallClockLabeledAsUtc.hour,
      wallClockLabeledAsUtc.minute,
      wallClockLabeledAsUtc.second,
    );
    return local.toUtc();
  }

  /// ISO-8601 with numeric offset for the device's current local time.
  static String nowWithLocalOffsetIso8601() {
    return withLocalOffsetIso8601(DateTime.now());
  }

  static String withLocalOffsetIso8601(DateTime dateTime) {
    final local = dateTime.isUtc ? dateTime.toLocal() : dateTime;
    final offset = local.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final abs = offset.abs();
    final hours = abs.inHours.toString().padLeft(2, '0');
    final minutes = (abs.inMinutes % 60).toString().padLeft(2, '0');
    String two(int n) => n.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}'
        'T${two(local.hour)}:${two(local.minute)}:${two(local.second)}'
        '$sign$hours:$minutes';
  }

  static String _safeZoneId(String timeZoneId) {
    try {
      tz.getLocation(timeZoneId);
      return timeZoneId;
    } catch (_) {
      return defaultId;
    }
  }
}
