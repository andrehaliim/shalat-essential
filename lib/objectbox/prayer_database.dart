import 'package:objectbox/objectbox.dart';

@Entity()
class PrayerDatabase {
  @Id()
  int id;

  String date;
  DateTime fajr;
  DateTime dhuhr;
  DateTime asr;
  DateTime maghrib;
  DateTime isha;
  bool notifFajr;
  bool notifDhuhr;
  bool notifAsr;
  bool notifMaghrib;
  bool notifIsha;
  bool doneFajr;
  bool doneDhuhr;
  bool doneAsr;
  bool doneMaghrib;
  bool doneIsha;

  PrayerDatabase({
    this.id = 0,
    required this.date,
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    this.notifFajr = false,
    this.notifDhuhr = false,
    this.notifAsr = false,
    this.notifMaghrib = false,
    this.notifIsha = false,
    this.doneFajr = false,
    this.doneDhuhr = false,
    this.doneAsr = false,
    this.doneMaghrib = false,
    this.doneIsha = false,
  });
}
