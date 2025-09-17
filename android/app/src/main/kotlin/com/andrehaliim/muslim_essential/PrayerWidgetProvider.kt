package com.andrehaliim.muslim_essential

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PrayerWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.prayer_widget_layout)

            val prefs = HomeWidgetPlugin.getData(context)
            views.setTextViewText(R.id.fajr_time, prefs.getString("fajr_time", "--:--"))
            views.setTextViewText(R.id.dhuhr_time, prefs.getString("dhuhr_time", "--:--"))
            views.setTextViewText(R.id.asr_time, prefs.getString("asr_time", "--:--"))
            views.setTextViewText(R.id.maghrib_time, prefs.getString("maghrib_time", "--:--"))
            views.setTextViewText(R.id.isha_time, prefs.getString("isha_time", "--:--"))

            // Click action to open Flutter app
            val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.prayer_widget_root, pendingIntent)

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
