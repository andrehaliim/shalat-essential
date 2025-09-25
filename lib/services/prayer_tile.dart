import 'package:flutter/material.dart';
import 'package:shalat_essential/services/colors.dart';
import 'package:shalat_essential/services/prayer_model.dart';

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