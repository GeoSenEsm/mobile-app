import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static final onClickNotification = BehaviorSubject<String>();
  static Future initialize() async {
    tz.initializeTimeZones();
    final String localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    const androidInit = AndroidInitializationSettings('@drawable/logo4');
    const iOSInize = DarwinInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: androidInit, iOS: iOSInize);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onTapNotification,
      onDidReceiveBackgroundNotificationResponse: _onTapNotification,
    );
  }

  static Future scheduleNotification(DateTime scheduledDate, EncodedID id,
      String title, String body, String payload) async {
    const androidDetails = AndroidNotificationDetails(
      'Reminder',
      'Reminder',
      importance: Importance.max,
      priority: Priority.high,
      largeIcon: DrawableResourceAndroidBitmap('@drawable/large_icon'),
    );

    const iOSDetails = DarwinNotificationDetails();

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      //TODO LOG IT
      return;
    }

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id.value,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      payload: payload,
    );
  }

  static Future<void> checkPendingNotificationRequests() async {
    if (!kDebugMode) return;

    await Future.delayed(const Duration(milliseconds: 200));
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('${pendingNotificationRequests.length} pending notification ');

    for (PendingNotificationRequest pendingNotificationRequest
        in pendingNotificationRequests) {
      print(
          "${pendingNotificationRequest.id} ${pendingNotificationRequest.payload ?? ""}");
    }
  }

  static Future cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  static Future cancelNotification(EncodedID id) async {
    // TODO manage it when offline
    await _flutterLocalNotificationsPlugin.cancel(id.value);
  }

  static void _onTapNotification(NotificationResponse notificationResponse) {
    onClickNotification.add(notificationResponse.payload!);
  }
}

EncodedID getSurveyNotificationID(String id, DateTime time) {
  const timeResidue = (Duration.minutesPerDay * 2 * 30); // 2 months
  final hashID = hash(id).toUnsigned(12).toInt();
  final timeComponentID =
      time.millisecondsSinceEpoch.milliseconds.inMinutes % timeResidue;
  final encodedID = int.parse("$timeComponentID${hashID}0").toSigned(32);

  return EncodedID(encodedID);
}

class EncodedID {
  final int value;

  EncodedID(this.value);
}
