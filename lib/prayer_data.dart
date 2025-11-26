import 'package:objectbox/objectbox.dart';

@Entity()
class PrayerData {
  @Id()
  int id;

  String date;
  DateTime fajr;
  DateTime dhuhr;
  DateTime asr;
  DateTime maghrib;
  DateTime isha;

  PrayerData({
    this.id = 0,
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });
}
