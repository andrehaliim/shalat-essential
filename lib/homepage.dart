import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:page_transition/page_transition.dart';
import 'package:shalat_essential/colors.dart';
import 'package:shalat_essential/compass.dart';
import 'package:shalat_essential/login.dart';
import 'package:shalat_essential/prayer_model.dart';
import 'package:shalat_essential/prefs_service.dart';
import 'package:shalat_essential/rotating_dot.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'get_location.dart';
import 'notification_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGetLocation = false;
  late Future<void> initFuture;
  String locationName = '';
  DateTime? _lastTime;
  Timer? _timer;
  String nextPrayer = '';
  String nextPrayerTime = '';
  String? nickname;
  bool isLoadingTracker = false;
  PrayerModel? todayPrayer;
  PrayerModel? yesterdayPrayer;
  DateTime todayDate = DateTime.now();
  DateTime yesterdayDate = DateTime.now().subtract(const Duration(days: 1));
  PrayerModel prayerModel = PrayerModel.empty();

  @override
  void initState() {
    super.initState();
    initFuture = initAll();
    _lastTime = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      DateTime now = DateTime.now();

      if (_lastTime?.minute != now.minute) {
        initAll();
        _lastTime = now;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> initAll() async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      isGetLocation = true;
    });
    final position = await determinePosition();
    await getLocationName(position);
    await getShalatData(position);
    await loadPrefs();
    if(user != null) {
      loadNickname();
      getTracker(user.uid);
    }
    setState(() {
      isGetLocation = false;
    });
  }

  Future<void> getLocationName(Position position) async {
    final latitude = position.latitude;
    final longitude = position.longitude;

    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    if (placemarks.isNotEmpty) {
      final place = placemarks.first;
      String location = '${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}';
      print('----- coordinate is latitude : $latitude | longitude : $longitude -----');
      print('----- location name is $location -----');
      setState(() {
        locationName = location;
      });
    }
  }

  Future<void> getShalatData(Position position) async {
    tz.initializeTimeZones();
    double latitude = position.latitude;
    double longitude = position.longitude;
    final location = tz.getLocation(tzmap.latLngToTimezoneString(latitude, longitude));
    DateTime date = tz.TZDateTime.from(DateTime.now(), location);
    Coordinates coordinates = Coordinates(latitude, longitude);
    CalculationParameters params = CalculationMethod.singapore();
    params.madhab = Madhab.shafi;

    PrayerTimes prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params);

    setState(() {
      prayerModel.fajrTime = tz.TZDateTime.from(prayerTimes.fajr!, location);
      prayerModel.dhuhrTime = tz.TZDateTime.from(prayerTimes.dhuhr!, location);
      prayerModel.asrTime = tz.TZDateTime.from(prayerTimes.asr!, location);
      prayerModel.maghribTime = tz.TZDateTime.from(prayerTimes.maghrib!, location);
      prayerModel.ishaTime = tz.TZDateTime.from(prayerTimes.isha!, location);
      DateTime nextTime;
      String prayerName;

      if (date.isBefore(prayerModel.fajrTime!)) {
        prayerName = "Fajr";
        nextTime = prayerModel.fajrTime!;
      } else if (date.isBefore(prayerModel.dhuhrTime!)) {
        prayerName = "Dhuhr";
        nextTime = prayerModel.dhuhrTime!;
      } else if (date.isBefore(prayerModel.asrTime!)) {
        prayerName = "Asr";
        nextTime = prayerModel.asrTime!;
      } else if (date.isBefore(prayerModel.maghribTime!)) {
        prayerName = "Maghrib";
        nextTime = prayerModel.maghribTime!;
      } else if (date.isBefore(prayerModel.ishaTime!)) {
        prayerName = "Isha";
        nextTime = prayerModel.ishaTime!;
      } else {
        prayerName = "Fajr";
        nextTime = prayerModel.fajrTime!.add(const Duration(days: 1));
      }

      Duration remaining = nextTime.difference(date);
      String hours = remaining.inHours.toString().padLeft(2, '0');
      String minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');

      nextPrayer = prayerName;
      nextPrayerTime = "in ${hours}h ${minutes}m";
      updatePrayerWidget(
          fajr: tz.TZDateTime.from(prayerTimes.fajr!, location),
          dhuhr:  tz.TZDateTime.from(prayerTimes.dhuhr!, location),
          asr:  tz.TZDateTime.from(prayerTimes.asr!, location),
          maghrib:  tz.TZDateTime.from(prayerTimes.maghrib!, location),
          isha:  tz.TZDateTime.from(prayerTimes.isha!, location)
      );
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      setState(() {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Logout successful")),
        );
        nickname = null;
        todayPrayer = null;
        yesterdayPrayer = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    final screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Muslim Essential'),
            GestureDetector(
              onTap: _logout,
              child: Icon(Icons.logout),
            ),
          ],
        ),
      ),
      body: FutureBuilder(
        future: initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: RotatingDot());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error getting location data'));
          } else {
            return Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Assalamualaikum,', style: Theme.of(context).textTheme.bodyMedium),
                    Text(nickname != null ? '$nickname' : 'Guest', style: Theme.of(context).textTheme.headlineLarge),
                    SizedBox(height: 20,),
                    GestureDetector(
                      onTap: initAll,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isGetLocation ? RotatingDot() : Icon(Icons.location_on, size: 20,),
                          Expanded(child: Text(locationName, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2,))
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Next prayer is,', style: Theme.of(context).textTheme.bodyMedium),
                                Text(nextPrayer, style: Theme.of(context).textTheme.headlineLarge),
                                Text(nextPrayerTime, style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: ElevatedButton(
                              style: Theme.of(context).elevatedButtonTheme.style,
                              onPressed: () async {
                                showPreviewDialog();
                              },
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.explore, size: 30, color: AppColors.primaryText),
                                  SizedBox(height: 5),
                                  Text('Qibla', style: Theme.of(context).textTheme.bodyMedium),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10,),
                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surface,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fajr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Dhuhr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Asr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Maghrib', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Isha', style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(DateFormat('HH:mm').format(prayerModel.fajrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(prayerModel.dhuhrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(prayerModel.asrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(prayerModel.maghribTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(prayerModel.ishaTime!), style: Theme.of(context).textTheme.bodyMedium),
                              ],
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                    onTap: () => toggleNotification("Fajr", prayerModel.fajrTime!, 1),
                                    child: !prayerModel.fajrNotif ? Icon(Icons.notifications_active_outlined, size: 20) : Icon(Icons.notifications_off_outlined, size: 20)),
                                GestureDetector(
                                    onTap: () => toggleNotification("Dhuhr", prayerModel.dhuhrTime!, 2),
                                    child: !prayerModel.dhuhrNotif ? Icon(Icons.notifications_active_outlined, size: 20) : Icon(Icons.notifications_off_outlined, size: 20)),
                                GestureDetector(
                                    onTap: () => toggleNotification("Asr", prayerModel.asrTime!, 3),
                                    child: !prayerModel.asrNotif ? Icon(Icons.notifications_active_outlined, size: 20) : Icon(Icons.notifications_off_outlined, size: 20)),
                                GestureDetector(
                                    onTap: () => toggleNotification("Maghrib", prayerModel.maghribTime!, 4),
                                    child: !prayerModel.maghribNotif ? Icon(Icons.notifications_active_outlined, size: 20) : Icon(Icons.notifications_off_outlined, size: 20)),
                                GestureDetector(
                                    onTap: () => toggleNotification("Isha", prayerModel.ishaTime!, 5),
                                    child: !prayerModel.ishaNotif ? Icon(Icons.notifications_active_outlined, size: 20) : Icon(Icons.notifications_off_outlined, size: 20)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Material(
                      elevation: 8,
                      borderRadius: BorderRadius.circular(10),
                      color: Theme.of(context).colorScheme.surface,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        padding: const EdgeInsets.all(10),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: screenWidth,
                                      height: screenHeight / 25,
                                      child: Text('Yesterday',
                                          style: Theme.of(context).textTheme.headlineMedium,
                                          textAlign: TextAlign.center),
                                    ),
                                    Text(DateFormat('EEEE').format(yesterdayDate), style: Theme.of(context).textTheme.bodyMedium),
                                    Text(DateFormat("dd MMMM yyyy").format(yesterdayDate),style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(height: 10),
                                    PrayerTile(prayerModel: yesterdayPrayer),
                                  ],
                                ),
                              ),
                              const VerticalDivider(
                                thickness: 2,
                                width: 40,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: screenWidth,
                                      height: screenHeight / 25,
                                      child: Text('Today',
                                          style: Theme.of(context).textTheme.headlineMedium,
                                          textAlign: TextAlign.center),
                                    ),
                                    Text(DateFormat('EEEE').format(todayDate), style: Theme.of(context).textTheme.bodyMedium),
                                    Text(DateFormat("dd MMMM yyyy").format(todayDate),style: Theme.of(context).textTheme.bodyMedium),
                                    const SizedBox(height: 10),
                                    PrayerTile(prayerModel: todayPrayer),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                          width: screenWidth,
                          height: kMinInteractiveDimension,
                          child: ElevatedButton(
                            style: Theme.of(context).elevatedButtonTheme.style,
                            onPressed: () async{
                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                bool refresh = await Navigator.push(
                                  context,
                                  PageTransition(
                                    type: PageTransitionType.rightToLeft,
                                    childBuilder: (context) => Login(),
                                  ),
                                );
                                if(refresh){
                                  initAll();
                                }
                              } else {
                                setState(() {
                                  isLoadingTracker = true;
                                });
                                await trackPrayer(user.uid);
                                setState(() {
                                  isLoadingTracker = false;
                                });
                              }
                            },
                            child: isLoadingTracker
                                ? RotatingDot()
                                : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.check_box_outlined, size: 30, color: AppColors.primaryText,),
                                    Text('Track Prayer', style: Theme.of(context).primaryTextTheme.labelLarge),
                                  ],
                                ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        }
      ),
    );
  }

  Future<void> loadNickname() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          nickname = doc.data()?["nickname"];
        });
      }
    }
  }

  Future<void> trackPrayer(String userId) async {
    final todayDoc = await getTracker(userId);
    if (todayDoc['today'] != null) {
      await updateTracker(userId);
    } else {
      await createTracker(userId);
    }
  }

  Future<PrayerModel> createTracker(String userId) async {
    final today = DateTime.now();
    final dateString =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    final times = {
      "fajr": prayerModel.fajrTime,
      "dhuhr": prayerModel.dhuhrTime,
      "asr": prayerModel.asrTime,
      "maghrib": prayerModel.maghribTime,
      "isha": prayerModel.ishaTime,
    };

    final currentPrayer = getCurrentTracker(today, times);

    final docRef = FirebaseFirestore.instance
        .collection('tracker')
        .doc(userId)
        .collection('prayer')
        .doc(dateString);

    final newDay = PrayerModel();
    final map = newDay.toMap();
    map[currentPrayer] = 1;
    await docRef.set(map);

    initAll();

    return newDay;
  }

  Future<Map<String, PrayerModel?>> getTracker(String userId) async {
    final now = DateTime.now();

    // format helper
    String formatDate(DateTime date) =>
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    final todayString = formatDate(now);
    final yesterdayString = formatDate(now.subtract(const Duration(days: 1)));

    final firestore = FirebaseFirestore.instance;

    // today doc
    final todayDoc = await firestore
        .collection('tracker')
        .doc(userId)
        .collection('prayer')
        .doc(todayString)
        .get();

    // yesterday doc
    final yesterdayDoc = await firestore
        .collection('tracker')
        .doc(userId)
        .collection('prayer')
        .doc(yesterdayString)
        .get();

    setState(() {
      todayPrayer = todayDoc.exists ? PrayerModel.fromMap(todayDoc.data()!) : null;
      yesterdayPrayer = yesterdayDoc.exists ? PrayerModel.fromMap(yesterdayDoc.data()!) : null;
    });

    return {
      "today": todayDoc.exists ? PrayerModel.fromMap(todayDoc.data()!) : null,
      "yesterday": yesterdayDoc.exists ? PrayerModel.fromMap(yesterdayDoc.data()!) : null,
    };
  }

  Future<void> updateTracker(String userId) async {
    final now = DateTime.now();

    final dateString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final times = {
      "fajr": prayerModel.fajrTime,
      "dhuhr": prayerModel.dhuhrTime,
      "asr": prayerModel.asrTime,
      "maghrib": prayerModel.maghribTime,
      "isha": prayerModel.ishaTime,
    };

    final currentPrayer = getCurrentTracker(now, times);

    await FirebaseFirestore.instance
        .collection('tracker')
        .doc(userId)
        .collection('prayer')
        .doc(dateString)
        .set({
      currentPrayer: 1,
    }, SetOptions(merge: true));
  }

  String getCurrentTracker(DateTime now, Map<String, DateTime?> times) {
    final orderedPrayers = [
      {"name": "fajr", "time": times["fajr"]!},
      {"name": "dhuhr", "time": times["dhuhr"]!},
      {"name": "asr", "time": times["asr"]!},
      {"name": "maghrib", "time": times["maghrib"]!},
      {"name": "isha", "time": times["isha"]!},
    ];

    String currentPrayer = "fajr";
    for (var prayer in orderedPrayers) {
      if (now.isAfter(prayer["time"] as DateTime)) {
        currentPrayer = prayer["name"] as String;
      }
    }
    return currentPrayer;
  }

  void toggleNotification(String prayerName, DateTime time, int id) async {
    setState(() {
      switch (id) {
        case 1: prayerModel.fajrNotif = !prayerModel.fajrNotif; PrefsService.savePrayerPrefs("fajr_notif", prayerModel.fajrNotif); break;
        case 2: prayerModel.dhuhrNotif = !prayerModel.dhuhrNotif; PrefsService.savePrayerPrefs("dhuhr_notif", prayerModel.dhuhrNotif); break;
        case 3: prayerModel.asrNotif = !prayerModel.asrNotif; PrefsService.savePrayerPrefs("asr_notif", prayerModel.asrNotif); break;
        case 4: prayerModel.maghribNotif = !prayerModel.maghribNotif; PrefsService.savePrayerPrefs("maghrib_notif", prayerModel.maghribNotif); break;
        case 5: prayerModel.ishaNotif = !prayerModel.ishaNotif; PrefsService.savePrayerPrefs("isha_notif", prayerModel.ishaNotif); break;
      }
    });

    if ((prayerModel.fajrNotif && id == 1) ||
        (prayerModel.dhuhrNotif && id == 2) ||
        (prayerModel.asrNotif && id == 3) ||
        (prayerModel.maghribNotif && id == 4) ||
        (prayerModel.ishaNotif && id == 5)) {
      // Schedule notification
      NotificationService.scheduleNotification(
        id: id,
        title: "Prayer Reminder",
        body: "$prayerName prayer will start in 5 minutes at ${DateFormat.Hm().format(time)}.",
        scheduledTime: time,
      );
    } else {
      // Cancel notification
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.cancel(id);
    }
  }

  Future<void> loadPrefs() async {
    prayerModel.fajrNotif = await PrefsService.getPrayerPrefs("fajr_notif");
    prayerModel.dhuhrNotif = await PrefsService.getPrayerPrefs("dhuhr_notif");
    prayerModel.asrNotif = await PrefsService.getPrayerPrefs("asr_notif");
    prayerModel.maghribNotif = await PrefsService.getPrayerPrefs("maghrib_notif");
    prayerModel.ishaNotif = await PrefsService.getPrayerPrefs("isha_notif");
    setState(() {});

    if (prayerModel.fajrTime != null &&
        prayerModel.dhuhrTime != null &&
        prayerModel.asrTime != null &&
        prayerModel.maghribTime != null &&
        prayerModel.ishaTime != null) {
      _rescheduleActiveNotifications();
    }
  }



  Future<void> _rescheduleActiveNotifications() async {
    DateTime adjustIfPast(DateTime time) {
      final now = DateTime.now();
      if (time.isBefore(now)) {
        return time.add(const Duration(days: 1)); // schedule for tomorrow
      }
      return time;
    }

    if (prayerModel.fajrTime != null && prayerModel.fajrNotif) {
      NotificationService.scheduleNotification(
        id: 1,
        title: "Prayer Reminder",
        body: "Fajr prayer will start in 5 minutes at ${DateFormat.Hm().format(prayerModel.fajrTime!)}.",
        scheduledTime: adjustIfPast(prayerModel.fajrTime!),
      );

      NotificationService.logNotification(adjustIfPast(prayerModel.fajrTime!), 1, true);
    }

    if (prayerModel.dhuhrTime != null && prayerModel.dhuhrNotif) {
      NotificationService.scheduleNotification(
        id: 2,
        title: "Prayer Reminder",
        body: "Dhuhr prayer will start in 5 minutes at ${DateFormat.Hm().format(prayerModel.dhuhrTime!)}.",
        scheduledTime: adjustIfPast(prayerModel.dhuhrTime!),
      );

      NotificationService.logNotification(adjustIfPast(prayerModel.dhuhrTime!), 2, true);
    }

    if (prayerModel.asrTime != null && prayerModel.asrNotif) {
      NotificationService.scheduleNotification(
        id: 3,
        title: "Prayer Reminder",
        body: "Asr prayer will start in 5 minutes at ${DateFormat.Hm().format(prayerModel.asrTime!)}.",
        scheduledTime: adjustIfPast(prayerModel.asrTime!),
      );

      NotificationService.logNotification(adjustIfPast(prayerModel.asrTime!), 3, true);
    }

    if (prayerModel.maghribTime != null && prayerModel.maghribNotif) {
      NotificationService.scheduleNotification(
        id: 4,
        title: "Prayer Reminder",
        body: "Maghrib prayer will start in 5 minutes at ${DateFormat.Hm().format(prayerModel.maghribTime!)}.",
        scheduledTime: adjustIfPast(prayerModel.maghribTime!),
      );

      NotificationService.logNotification(adjustIfPast(prayerModel.maghribTime!), 4, true);
    }

    if (prayerModel.ishaTime != null && prayerModel.ishaNotif) {
      NotificationService.scheduleNotification(
        id: 5,
        title: "Prayer Reminder",
        body: "Isha prayer will start in 5 minutes at ${DateFormat.Hm().format(prayerModel.ishaTime!)}.",
        scheduledTime: adjustIfPast(prayerModel.ishaTime!),
      );

      NotificationService.logNotification(adjustIfPast(prayerModel.ishaTime!), 5, true);
    }
  }

  showPreviewDialog() async {

    return showDialog(
        context: context,
        builder: (context) => Dialog(
            insetPadding: EdgeInsets.all(10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: AppColors.background
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Spacer(),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.close),
                      )
                    ],
                  ),
                  Text('Qibla Compass', style: Theme.of(context).textTheme.headlineMedium),
                  SizedBox(height: 10,),
                  Compass(),
                  SizedBox(height: 10,),
                ],
              ),
            )));
  }

  Future<void> updatePrayerWidget({
    required DateTime fajr,
    required DateTime dhuhr,
    required DateTime asr,
    required DateTime maghrib,
    required DateTime isha,
  }) async {
    await HomeWidget.saveWidgetData<String>('fajr_time', DateFormat('HH:mm').format(fajr));
    await HomeWidget.saveWidgetData<String>('dhuhr_time', DateFormat('HH:mm').format(dhuhr));
    await HomeWidget.saveWidgetData<String>('asr_time', DateFormat('HH:mm').format(asr));
    await HomeWidget.saveWidgetData<String>('maghrib_time', DateFormat('HH:mm').format(maghrib));
    await HomeWidget.saveWidgetData<String>('isha_time', DateFormat('HH:mm').format(isha));

    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
    );
  }
}

class PrayerTile extends StatelessWidget {
  final PrayerModel? prayerModel;

  const PrayerTile({
    super.key,
    this.prayerModel,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (prayerModel != null) {
      int completed = prayerModel!.fajr + prayerModel!.dhuhr + prayerModel!.asr + prayerModel!.maghrib + prayerModel!.isha;

      return Column(
        children: [
          Row(
            children: [
              Icon(
                prayerModel!.fajr == 1
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: prayerModel!.fajr == 1
                    ? AppColors.highlightBlue
                    : AppColors.borderColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Fajr', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Icon(
                prayerModel!.dhuhr == 1
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: prayerModel!.dhuhr == 1
                    ? AppColors.highlightBlue
                    : AppColors.borderColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Dhuhr', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Icon(
                prayerModel!.asr == 1
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: prayerModel!.asr == 1
                    ? AppColors.highlightBlue
                    : AppColors.borderColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Asr', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Icon(
                prayerModel!.maghrib == 1
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: prayerModel!.maghrib == 1
                    ? AppColors.highlightBlue
                    : AppColors.borderColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Maghrib', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          Row(
            children: [
              Icon(
                prayerModel!.isha == 1
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                color: prayerModel!.isha == 1
                    ? AppColors.highlightBlue
                    : AppColors.borderColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text('Isha', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: screenWidth,
            child: Text('Completed: $completed/5',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center),
          ),
        ],
      );
    } else {
      return Text('No data', style: Theme.of(context).textTheme.bodyMedium);
    }
  }
}
