import 'package:adhan_dart/adhan_dart.dart';
import 'package:timezone/timezone.dart' as tz;

class PrayerModel {
  final String date;
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
  bool fajrNotif;
  bool dhuhrNotif;
  bool asrNotif;
  bool maghribNotif;
  bool ishaNotif;
  DateTime? fajrTime;
  DateTime? dhuhrTime;
  DateTime? asrTime;
  DateTime? maghribTime;
  DateTime? ishaTime;

  PrayerModel({
    this.date = '',
    this.fajr = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
    this.fajrNotif = false,
    this.dhuhrNotif = false,
    this.asrNotif = false,
    this.maghribNotif = false,
    this.ishaNotif = false,
    this.fajrTime,
    this.dhuhrTime,
    this.asrTime,
    this.maghribTime,
    this.ishaTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'fajr': fajr,
      'dhuhr': dhuhr,
      'asr': asr,
      'maghrib': maghrib,
      'isha': isha,
    };
  }

  factory PrayerModel.fromMap(String dateTime, Map<String, dynamic> map) {
    return PrayerModel(
      date: dateTime,
      fajr: map['fajr'] ?? 0,
      dhuhr: map['dhuhr'] ?? 0,
      asr: map['asr'] ?? 0,
      maghrib: map['maghrib'] ?? 0,
      isha: map['isha'] ?? 0,
    );
  }

  factory PrayerModel.empty(String? dateTime) {
    return PrayerModel(
      date: dateTime ?? '',
      fajr : 0,
      dhuhr : 0,
      asr : 0,
      maghrib : 0,
      isha : 0,
      fajrNotif : false,
      dhuhrNotif : false,
      asrNotif : false,
      maghribNotif : false,
      ishaNotif : false,
    );
  }
}

class PrayerResult {
  final PrayerTimes prayerTimes;
  final tz.Location location;
  final DateTime dateTime;

  PrayerResult({required this.prayerTimes, required this.location, required this.dateTime});
}