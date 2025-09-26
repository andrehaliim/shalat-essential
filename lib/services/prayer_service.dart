import 'package:adhan_dart/adhan_dart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:shalat_essential/services/prayer_model.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:timezone/timezone.dart' as tz;

class PrayerService {
  static Future<PrayerResult> getShalatData(Position position) async {
    tzl.initializeTimeZones();
    double latitude = position.latitude;
    double longitude = position.longitude;
    final location = tz.getLocation(tzmap.latLngToTimezoneString(latitude, longitude));
    DateTime date = tz.TZDateTime.from(DateTime.now(), location);
    Coordinates coordinates = Coordinates(latitude, longitude);
    CalculationParameters params = CalculationMethod.singapore();
    params.madhab = Madhab.shafi;
    PrayerTimes prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params);

    return PrayerResult(prayerTimes: prayerTimes, location: location, dateTime: date);
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

    return {
      "today": todayDoc.exists ? PrayerModel.fromMap(todayDoc.data()!) : null,
      "yesterday": yesterdayDoc.exists ? PrayerModel.fromMap(yesterdayDoc.data()!) : null,
    };
  }

  Future<bool> trackPrayer(BuildContext context, String userId, PrayerModel prayerModel) async {
    final todayDoc = await getTracker(userId);
    if (todayDoc['today'] != null) {
      await updateTracker(context, userId, prayerModel);
      return true;
    } else {
      await createTracker(userId, prayerModel);
      return true;
    }
  }

  Future<PrayerModel> createTracker(String userId, PrayerModel prayerModel) async {
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

    return newDay;
  }

  Future<void> updateTracker(BuildContext context, String userId, PrayerModel prayerModel) async {
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

    final docRef = FirebaseFirestore.instance
        .collection('tracker')
        .doc(userId)
        .collection('prayer')
        .doc(dateString);

    final docSnap = await docRef.get();

    if (docSnap.exists && docSnap.data()?[currentPrayer] == 1) {
      // Already tracked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Already tracked prayer")),
      );
      return;
    }

    // Not tracked yet → update
    await docRef.set({
      currentPrayer: 1,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("$currentPrayer tracked successfully")),
    );
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

  static Future<PrayerResult> getShalatDataBackground(double latitude, double longitude) async {
    tzl.initializeTimeZones();
    final location = tz.getLocation(tzmap.latLngToTimezoneString(latitude, longitude));
    DateTime date = tz.TZDateTime.from(DateTime.now(), location);
    Coordinates coordinates = Coordinates(latitude, longitude);
    CalculationParameters params = CalculationMethod.singapore();
    params.madhab = Madhab.shafi;
    PrayerTimes prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params);

    return PrayerResult(prayerTimes: prayerTimes, location: location, dateTime: date);
  }
}