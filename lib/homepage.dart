import 'package:flutter/material.dart';
import 'package:shalat_essential/colors.dart';
import 'package:shalat_essential/rotating_dot.dart';
import 'package:shalat_essential/theme_button.dart';

import 'get_location.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isGetLocation = false;
  late Future<String> positionFuture;

  @override
  void initState() {
    super.initState();
    positionFuture = determinePosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shalat Essential'),
        actions: const [
          ThemeToggleButton(),
        ],
      ),
      body: FutureBuilder(
        future: positionFuture,
        builder: (context, asyncSnapshot) {
          if(asyncSnapshot.hasData){
            String position = asyncSnapshot.data!;
            return Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () async{
                        setState(() {
                          positionFuture = determinePosition();
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 20,),
                          Expanded(child: Text(position, style: Theme.of(context).textTheme.bodyMedium, maxLines: 2,))
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    Text('Dzuhur 12:10', style: Theme.of(context).textTheme.headlineLarge),
                    Text('4h 13m left', style: Theme.of(context).textTheme.bodyMedium),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Subuh', style: Theme.of(context).textTheme.bodyMedium),
                              Text('Dzuhur', style: Theme.of(context).textTheme.bodyMedium),
                              Text('Ashar', style: Theme.of(context).textTheme.bodyMedium),
                              Text('Magrib', style: Theme.of(context).textTheme.bodyMedium),
                              Text('Isya', style: Theme.of(context).textTheme.bodyMedium),
                            ]
                          ),
                          Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('04:45', style: Theme.of(context).textTheme.bodyMedium),
                              Text('04:45', style: Theme.of(context).textTheme.bodyMedium),
                              Text('04:45', style: Theme.of(context).textTheme.bodyMedium),
                              Text('04:45', style: Theme.of(context).textTheme.bodyMedium),
                              Text('04:45', style: Theme.of(context).textTheme.bodyMedium),
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
                              color: AppColors.cardBackground2,
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
                              color: AppColors.cardBackground2,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_box_outlined, size: 30,),
                                SizedBox(width: 5,),
                                Text('Track Shalat', style: Theme.of(context).textTheme.bodyMedium)
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
                        color: AppColors.cardBackground2,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Senin, 05 Agustus 2025', style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 10,),
                            PrayerTile(name: 'Subuh', time: '04:38 AM', checked: true),
                            PrayerTile(name: 'Dzuhur', time: '12:04 PM', checked: false),
                            PrayerTile(name: 'Ashar', time: '15:22 PM', checked: false),
                            PrayerTile(name: 'Maghrib', time: '17:58 PM', checked: false),
                            PrayerTile(name: 'Isya', time: '19:15 PM', checked: false),
                            SizedBox(height: 10,),
                            Text('Progress: 1/5', style: Theme.of(context).textTheme.bodyMedium),
                          ]
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if(asyncSnapshot.hasError) {
            return Center(child: Text('Error getting location data'));
          } else {
            return Center(child: RotatingDot());
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