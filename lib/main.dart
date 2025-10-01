import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shalat_essential/services/prayer_service.dart';
import 'package:shalat_essential/views/homepage.dart';
import 'package:shalat_essential/services/themedata.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:timezone/data/latest.dart' as tzl;

import 'services/firebase_options.dart';
import 'services/notification_service.dart';

const updateWidgetTask = "updateWidgetTask";

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    tzl.initializeTimeZones();
    final prefs = await SharedPreferences.getInstance();

    String location = prefs.getString('location') ?? 'Failed to get saved location';
    double latitude = prefs.getDouble('lat') ?? 0.0;
    double longitude = prefs.getDouble('long') ?? 0.0;
    bool fajrNotif = prefs.getBool("fajr_notif") ?? false;
    bool dhuhrNotif = prefs.getBool("dhuhr_notif") ?? false;
    bool asrNotif = prefs.getBool("asr_notif") ?? false;
    bool maghribNotif = prefs.getBool("maghrib_notif") ?? false;
    bool ishaNotif = prefs.getBool("isha_notif") ?? false;

    final value = await PrayerService.getShalatDataBackground(latitude, longitude);

    switch (task) {
      case updateWidgetTask:
      // Prayer times
        await HomeWidget.saveWidgetData<String>('fajr_time', value.prayerTimes.fajr != null ? DateFormat('HH:mm').format(value.prayerTimes.fajr!) : '--:--');
        await HomeWidget.saveWidgetData<String>('dhuhr_time', value.prayerTimes.dhuhr != null ? DateFormat('HH:mm').format(value.prayerTimes.dhuhr!) : '--:--');
        await HomeWidget.saveWidgetData<String>('asr_time', value.prayerTimes.asr != null ? DateFormat('HH:mm').format(value.prayerTimes.asr!) : '--:--');
        await HomeWidget.saveWidgetData<String>('maghrib_time', value.prayerTimes.maghrib != null ? DateFormat('HH:mm').format(value.prayerTimes.maghrib!) : '--:--');
        await HomeWidget.saveWidgetData<String>('isha_time', value.prayerTimes.isha != null ? DateFormat('HH:mm').format(value.prayerTimes.isha!) : '--:--');

        // Reschedule Notification
        if (value.prayerTimes.fajr != null && fajrNotif) {
          NotificationService.scheduleNotification(
            id: 1,
            title: "Prayer Reminder",
            body: "Fajr prayer will start in 5 minutes at ${DateFormat.Hm().format(value.prayerTimes.fajr!)}.",
            scheduledTime: value.prayerTimes.fajr!,
          );
        }
        if (value.prayerTimes.dhuhr != null && dhuhrNotif) {
          NotificationService.scheduleNotification(
            id: 2,
            title: "Prayer Reminder",
            body: "Dhuhr prayer will start in 5 minutes at ${DateFormat.Hm().format(value.prayerTimes.dhuhr!)}.",
            scheduledTime: value.prayerTimes.dhuhr!,
          );
        }
        if (value.prayerTimes.asr != null && asrNotif) {
          NotificationService.scheduleNotification(
            id: 3,
            title: "Prayer Reminder",
            body: "Asr prayer will start in 5 minutes at ${DateFormat.Hm().format(value.prayerTimes.asr!)}.",
            scheduledTime: value.prayerTimes.asr!,
          );
        }
        if (value.prayerTimes.maghrib != null && maghribNotif) {
          NotificationService.scheduleNotification(
            id: 4,
            title: "Prayer Reminder",
            body: "Maghrib prayer will start in 5 minutes at ${DateFormat.Hm().format(value.prayerTimes.maghrib!)}.",
            scheduledTime: value.prayerTimes.maghrib!,
          );
        }
        if (value.prayerTimes.isha != null && ishaNotif) {
          NotificationService.scheduleNotification(
            id: 5,
            title: "Prayer Reminder",
            body: "Isha prayer will start in 5 minutes at ${DateFormat.Hm().format(value.prayerTimes.isha!)}.",
            scheduledTime: value.prayerTimes.isha!,
          );
        }

        // Reset checks
        await HomeWidget.saveWidgetData<bool>('fajr_check', false);
        await HomeWidget.saveWidgetData<bool>('dhuhr_check', false);
        await HomeWidget.saveWidgetData<bool>('asr_check', false);
        await HomeWidget.saveWidgetData<bool>('maghrib_check', false);
        await HomeWidget.saveWidgetData<bool>('isha_check', false);

        // Save extra info
        await HomeWidget.saveWidgetData<String>('location_name', location);
        await HomeWidget.saveWidgetData<String>('date_time', DateFormat('dd MMM yyyy HH:mm').format(DateTime.now()));

        await HomeWidget.updateWidget(name: 'PrayerWidgetProvider');
        break;
      default:
        return Future.value(false);
    }
    return Future.value(true);
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize WorkManager FIRST
  await Workmanager().initialize(
    callbackDispatcher
  );

  // Then init Firebase and Notifications
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  // Schedule periodic task (replace if already scheduled)
  final now = DateTime.now();
  final tomorrow = DateTime(now.year, now.month, now.day + 1, 0, 1);
  final updateWidgetDelay = tomorrow.difference(now);

  await Workmanager().registerPeriodicTask(
    updateWidgetTask,
    updateWidgetTask,
    frequency: const Duration(hours: 24),
    initialDelay: updateWidgetDelay,
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'Muslim Essential',
      theme: appLightTheme,
      darkTheme: appDarkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
