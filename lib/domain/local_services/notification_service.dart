import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  static Future initialize() async {
    tz.initializeTimeZones();
    final String localTimeZone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimeZone));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInize = DarwinInitializationSettings();
    const initializationSettings =
        InitializationSettings(android: androidInit, iOS: iOSInize);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future scheduleNotification(
      DateTime scheduledDate, int id, String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'Reminder',
      'Reminder',
      importance: Importance.max,
      priority: Priority.high,
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
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static Future<void> checkPendingNotificationRequests() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
    print('${pendingNotificationRequests.length} pending notification ');

    for (PendingNotificationRequest pendingNotificationRequest
        in pendingNotificationRequests) {
      print(
          "${pendingNotificationRequest.id} ${pendingNotificationRequest.payload ?? ""}");
    }
    print('NOW ${tz.TZDateTime.now(tz.local)}');
  }

  static Future cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    // TODO manage it when offline
  }
}
