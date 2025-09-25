import 'package:home_widget/home_widget.dart';
import 'package:intl/intl.dart';
import 'package:shalat_essential/services/prayer_model.dart';

class WidgetUpdate {
  Future<void> updateWidgetPrayerTime({
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

    await HomeWidget.saveWidgetData<String>('date_time', DateFormat('dd MMMM yyyy').format(DateTime.now()));

    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
    );
  }

  Future<void> updateWidgetPrayerNotification({required String name,required bool notification}) async {
    await HomeWidget.saveWidgetData<bool>('${name.toLowerCase()}_notification', notification);
    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
    );
  }

  Future<void> updateWidgetPrayerTracker({required PrayerModel? prayerModel}) async {
    if(prayerModel != null){
      await HomeWidget.saveWidgetData<bool>('fajr_check', prayerModel.fajr == 1 ? true : false);
      await HomeWidget.saveWidgetData<bool>('dhuhr_check', prayerModel.dhuhr == 1 ? true : false);
      await HomeWidget.saveWidgetData<bool>('asr_check', prayerModel.asr == 1 ? true : false);
      await HomeWidget.saveWidgetData<bool>('maghrib_check', prayerModel.maghrib == 1 ? true : false);
      await HomeWidget.saveWidgetData<bool>('isha_check', prayerModel.isha == 1 ? true : false);
    } else {
      await HomeWidget.saveWidgetData<bool>('fajr_check', false);
      await HomeWidget.saveWidgetData<bool>('dhuhr_check',false);
      await HomeWidget.saveWidgetData<bool>('asr_check', false);
      await HomeWidget.saveWidgetData<bool>('maghrib_check', false);
      await HomeWidget.saveWidgetData<bool>('isha_check', false);
    }

    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
    );
  }

  Future<void> updateWidgetLocation({required String location}) async {
    await HomeWidget.saveWidgetData<String>('location_name', location);
    await HomeWidget.updateWidget(
      name: 'PrayerWidgetProvider',
    );
  }
}