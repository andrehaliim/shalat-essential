import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shalat_essential/components/rotating_dot.dart';
import 'package:shalat_essential/services/colors.dart';
import 'package:shalat_essential/services/prayer_model.dart';
import 'package:shalat_essential/services/prayer_service.dart';

class History extends StatefulWidget {
  final User user;
  const History({super.key, required this.user});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {
  late Future<List<PrayerModel>> listPrayer;
  late int currentMonth;
  late int currentYear;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    currentMonth = now.month;
    currentYear = now.year;
    _loadData();
  }

  void _loadData() {
    setState(() {
      listPrayer = PrayerService().getAllTrackerData(
        widget.user.uid,
        year: currentYear,
        month: currentMonth,
      );
    });
  }

  void _previousMonth() {
    if (currentMonth == 1) {
      currentMonth = 12;
      currentYear--;
    } else {
      currentMonth--;
    }
    _loadData();
  }

  void _nextMonth() {
    if (currentMonth == 12) {
      currentMonth = 1;
      currentYear++;
    } else {
      currentMonth++;
    }
    _loadData();
  }

  String _monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    //final screenHeight = size.height;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.pop(context, true);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: const Text('Muslim Essential'), backgroundColor: AppColors.background, surfaceTintColor: Colors.transparent,),
        body: FutureBuilder<List<PrayerModel>>(
          future: listPrayer,
          builder: (context, asyncSnapshot) {
            if(asyncSnapshot.connectionState == ConnectionState.waiting){
              return Center(child: RotatingDot());
            } else if(asyncSnapshot.hasError) {
              return Center(child: Text('Error fetching prayer data', style: Theme.of(context).textTheme.bodyMedium));
            }
              List<PrayerModel> listData = asyncSnapshot.data!;
              return Container(
                width: screenWidth,
                padding: const EdgeInsets.only(top: 10, right: 10, left: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back_ios),
                          onPressed: _previousMonth,
                        ),
                        Spacer(),
                        Text(
                          "${_monthName(currentMonth)} $currentYear",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Spacer(),
                        IconButton(
                          icon: const Icon(Icons.arrow_forward_ios),
                          onPressed: _nextMonth,
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      child:  Row(
                        children: [
                          Expanded(flex: 1, child: Text("Day", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.start,)),
                          Expanded(flex: 2, child: Text("Fajr", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("Dhuhr", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("Asr", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("Maghrib", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                          Expanded(flex: 2, child: Text("Isha", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center)),
                          Expanded(flex: 1, child: Icon(Icons.check_circle, color: AppColors.highlightBlue, size: 20,)),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: listData.length,
                        itemBuilder: (context, index) {
                          final data = listData[index];

                          String prayerDate = '';
                          int prayerCompleted = data.fajr + data.dhuhr + data.asr + data.maghrib + data.isha;
                          IconData? prayerIconFajr = data.fajr == 1 ? Icons.check_circle : Icons.radio_button_unchecked;
                          IconData? prayerIconDhuhr = data.dhuhr == 1 ? Icons.check_circle : Icons.radio_button_unchecked;
                          IconData? prayerIconAsr = data.asr == 1 ? Icons.check_circle : Icons.radio_button_unchecked;
                          IconData? prayerIconMaghrib = data.maghrib == 1 ? Icons.check_circle : Icons.radio_button_unchecked;
                          IconData? prayerIconIsha = data.isha == 1 ? Icons.check_circle : Icons.radio_button_unchecked;

                          Color? prayerColorFajr = data.fajr == 1 ? AppColors.highlightBlue : AppColors.borderColor;
                          Color? prayerColorDhuhr = data.dhuhr == 1 ? AppColors.highlightBlue : AppColors.borderColor;
                          Color? prayerColorAsr = data.asr == 1 ? AppColors.highlightBlue : AppColors.borderColor;
                          Color? prayerColorMaghrib = data.maghrib == 1 ? AppColors.highlightBlue : AppColors.borderColor;
                          Color? prayerColorIsha = data.isha == 1 ? AppColors.highlightBlue : AppColors.borderColor;

                          final parts = data.date.split('-');
                          if (parts.length == 3) {
                            prayerDate =  parts[2]; // 01/09
                          }
                          return Container(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                Expanded(flex: 1, child: Text(prayerDate, style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.start,)),
                                Expanded(flex: 2, child: Icon(prayerIconFajr, color: prayerColorFajr, size: 20,)),
                                Expanded(flex: 2, child: Icon(prayerIconDhuhr, color: prayerColorDhuhr, size: 20)),
                                Expanded(flex: 2, child: Icon(prayerIconAsr, color: prayerColorAsr, size: 20)),
                                Expanded(flex: 2, child: Icon(prayerIconMaghrib, color: prayerColorMaghrib, size: 20)),
                                Expanded(flex: 2, child: Icon(prayerIconIsha, color: prayerColorIsha, size: 20)),
                                Expanded(flex: 1, child: Text("$prayerCompleted/5", style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.end)),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
          }
        ),
      ),
    );
  }
}
