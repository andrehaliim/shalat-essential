class PrayerModel {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  PrayerModel({
    this.fajr = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
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

  factory PrayerModel.fromMap(Map<String, dynamic> map) {
    return PrayerModel(
      fajr: map['fajr'] ?? 0,
      dhuhr: map['dhuhr'] ?? 0,
      asr: map['asr'] ?? 0,
      maghrib: map['maghrib'] ?? 0,
      isha: map['isha'] ?? 0,
    );
  }
}