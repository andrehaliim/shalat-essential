import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _notifications.initialize(initSettings);

    await requestPermissions();
  }

  static Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation =
      _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } else if (Platform.isIOS) {
      final iosImplementation =
      _notifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await iosImplementation?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  static Future<void> showNotification({required int id, required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }

  static Future<void> scheduleNotification({required int id, required String title, required String body, required DateTime? scheduledTime}) async {
    print(scheduledTime);
    await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10)),
        const NotificationDetails(
            android: AndroidNotificationDetails(
              'your channel id',
              'your channel name',
              channelDescription: 'your channel description',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
              enableVibration: true
            )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle);
  }

  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
