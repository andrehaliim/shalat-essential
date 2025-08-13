import 'dart:async';

import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:lat_lng_to_timezone/lat_lng_to_timezone.dart' as tzmap;
import 'package:shalat_essential/colors.dart';
import 'package:shalat_essential/rotating_dot.dart';
import 'package:shalat_essential/theme_button.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'get_location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGetLocation = false;
  late Future<void> initFuture;
  String locationName = '';
  DateTime? fajrTime;
  DateTime? dhuhrTime;
  DateTime? asrTime;
  DateTime? maghribTime;
  DateTime? ishaTime;
  Duration? timeLeft;
  String? nextPrayer;
  DateTime? _lastTime;
  Timer? _timer;

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
    setState(() {
      isGetLocation = true;
    });
    final position = await determinePosition();
    await getLocationName(position);
    await getShalatData(position);
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

    PrayerTimes prayerTimes = PrayerTimes(coordinates: coordinates, date: date, calculationParameters: params, precision: true);
    nextPrayer = prayerTimes.nextPrayer(date: date);
    DateTime? nextPrayerTime;
    nextPrayerTime = {
      Prayer.fajr: prayerTimes.fajr,
      Prayer.dhuhr: prayerTimes.dhuhr,
      Prayer.asr: prayerTimes.asr,
      Prayer.maghrib: prayerTimes.maghrib,
      Prayer.isha: prayerTimes.isha,
    }[nextPrayer];

    timeLeft = nextPrayerTime!.difference(date);

    print('----- getting prayer time for $location -----');
    print('----- next prayer is ${prayerTimes.nextPrayer(date: date)} -----');
    print('----- time left before next prayer is ${timeLeft!.inHours}h ${timeLeft!.inMinutes.remainder(60)}m -----');

    setState(() {
      fajrTime = tz.TZDateTime.from(prayerTimes.fajr!, location);
      dhuhrTime = tz.TZDateTime.from(prayerTimes.dhuhr!, location);
      asrTime = tz.TZDateTime.from(prayerTimes.asr!, location);
      maghribTime = tz.TZDateTime.from(prayerTimes.maghrib!, location);
      ishaTime = tz.TZDateTime.from(prayerTimes.isha!, location);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muslim Essential'),
        actions: const [
          ThemeToggleButton(),
        ],
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
                    Text('Next prayer is,', style: Theme.of(context).textTheme.bodyMedium),
                    Text(nextPrayer!.toUpperCase(), style: Theme.of(context).textTheme.headlineLarge),
                    Text('${timeLeft!.inHours}h ${timeLeft!.inMinutes.remainder(60)}m left', style: Theme.of(context).textTheme.bodyMedium),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Fajr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Dhuhr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Asr', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Magrib', style: Theme.of(context).textTheme.bodyMedium),
                                Text('Isha', style: Theme.of(context).textTheme.bodyMedium),
                              ]
                          ),
                          Spacer(),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(DateFormat('HH:mm').format(fajrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(dhuhrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(asrTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(maghribTime!), style: Theme.of(context).textTheme.bodyMedium),
                                Text(DateFormat('HH:mm').format(ishaTime!), style: Theme.of(context).textTheme.bodyMedium),
                              ]
                          ),
                          SizedBox(width: 10),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Icon(Icons.notifications_active, size: 20),
                                Icon(Icons.notifications_active, size: 20),
                                Icon(Icons.notifications_active, size: 20),
                                Icon(Icons.notifications_active, size: 20),
                                Icon(Icons.notifications_active, size: 20),
                              ]
                          )
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.compass_calibration_outlined, size: 30,),
                                SizedBox(width: 5,),
                                Text('Kompas Kiblat', style: Theme.of(context).textTheme.bodyMedium)
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: 20,),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_box_outlined, size: 30,),
                                SizedBox(width: 5,),
                                Text('Track Prayer', style: Theme.of(context).textTheme.bodyMedium)
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Minggu,', style: Theme.of(context).textTheme.bodyMedium),
                                  Text('03 Agustus 2025', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(height: 10,),
                                  PrayerTile(name: 'Fajr', time: '04:38 AM', checked: false),
                                  PrayerTile(name: 'Dhuhr', time: '12:04 PM', checked: true),
                                  PrayerTile(name: 'Asr', time: '15:22 PM', checked: true),
                                  PrayerTile(name: 'Maghrib', time: '17:58 PM', checked: true),
                                  PrayerTile(name: 'Isha', time: '19:15 PM', checked: true),
                                  SizedBox(height: 10,),
                                  Text('Progress: 4/5', style: Theme.of(context).textTheme.bodyMedium),
                                ]
                            ),
                          ),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Senin,', style: Theme.of(context).textTheme.bodyMedium),
                                  Text('04 Agustus 2025', style: Theme.of(context).textTheme.bodyMedium),
                                  SizedBox(height: 10,),
                                  PrayerTile(name: 'Fajr', time: '04:38 AM', checked: true),
                                  PrayerTile(name: 'Dhuhr', time: '12:04 PM', checked: false),
                                  PrayerTile(name: 'Asr', time: '15:22 PM', checked: false),
                                  PrayerTile(name: 'Maghrib', time: '17:58 PM', checked: false),
                                  PrayerTile(name: 'Isha', time: '19:15 PM', checked: false),
                                  SizedBox(height: 10,),
                                  Text('Progress: 1/5', style: Theme.of(context).textTheme.bodyMedium),
                                ]
                            ),
                          ),
                        ],
                      ),
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
}
class PrayerTile extends StatelessWidget {
  final String name;
  final String time;
  final bool checked;

  const PrayerTile({
    super.key,
    required this.name,
    required this.time,
    required this.checked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: checked ? AppColors.highlightBlue : AppColors.borderColor,
          size: 20,
        ),
        SizedBox(width: 10,),
        Text(name, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}