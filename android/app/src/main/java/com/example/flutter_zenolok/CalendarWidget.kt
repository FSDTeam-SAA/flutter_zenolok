package com.example.flutter_zenolok

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale
import androidx.core.net.toUri

class CalendarWidget : AppWidgetProvider() {

    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    // This makes the widget update at midnight + when user changes date/time
    override fun onReceive(context: Context?, intent: Intent?) {
        super.onReceive(context, intent)

        if (context == null) return

        val action = intent?.action
        if (action == Intent.ACTION_DATE_CHANGED ||
            action == Intent.ACTION_TIME_CHANGED ||
            action == Intent.ACTION_TIMEZONE_CHANGED ||
            action == AppWidgetManager.ACTION_APPWIDGET_UPDATE
        ) {
            val appWidgetManager = AppWidgetManager.getInstance(context)
            val thisWidget = ComponentName(context, CalendarWidget::class.java)
            val ids = appWidgetManager.getAppWidgetIds(thisWidget)
            onUpdate(context, appWidgetManager, ids)
        }
    }

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        // Schedule daily update at midnight
        scheduleMidnightUpdate(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // Cancel the alarm when last widget is removed
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(context, CalendarWidget::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            context, 0, intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        alarmManager.cancel(pendingIntent)
    }

    // ADD THIS FUNCTION — THIS IS THE MAGIC FIX
    override fun onRestored(context: Context?, oldWidgetIds: IntArray?, newWidgetIds: IntArray?) {
        super.onRestored(context, oldWidgetIds, newWidgetIds)
        context?.let {
            val appWidgetManager = AppWidgetManager.getInstance(it)
            val componentName = ComponentName(it, CalendarWidget::class.java)
            val appWidgetIds = appWidgetManager.getAppWidgetIds(componentName)
            onUpdate(it, appWidgetManager, appWidgetIds)
        }
    }
}

private fun updateAppWidget(context: Context, appWidgetManager: AppWidgetManager, appWidgetId: Int) {
    // This matches your actual file: calendar_widget.xml
    val views = RemoteViews(context.packageName, R.layout.calendar_widget)

    val now = Calendar.getInstance()

    // Day of week
    val dayOfWeek = now.getDisplayName(Calendar.DAY_OF_WEEK, Calendar.LONG, Locale.getDefault())
    views.setTextViewText(R.id.tv_day_of_week, dayOfWeek ?: "Day")

    // Day number
    views.setTextViewText(R.id.tv_day, now.get(Calendar.DAY_OF_MONTH).toString())

    // Month + Year
    val monthYear = SimpleDateFormat("MMMM yyyy", Locale.getDefault()).format(now.time)
    views.setTextViewText(R.id.tv_month_year, monthYear)

    // Click → Open YOUR Flutter app (not Google Calendar)
    val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK)

    val pendingIntent = PendingIntent.getActivity(
        context, 0, launchIntent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.root_layout, pendingIntent)

    appWidgetManager.updateAppWidget(appWidgetId, views)
}

private fun scheduleMidnightUpdate(context: Context) {
    val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager

    // CRITICAL: Check if we can schedule exact alarms (Android 12+)
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) { // Android 12+
        if (!alarmManager.canScheduleExactAlarms()) {
            // User hasn't granted permission yet → ask them
            val intent = Intent(android.provider.Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM).apply {
                data = "package:${context.packageName}".toUri()
            }
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
            return  // Don't schedule yet — user will come back after granting
        }
    }

    val intent = Intent(context, CalendarWidget::class.java)
    val pendingIntent = PendingIntent.getBroadcast(
        context, 0, intent,
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    val calendar = Calendar.getInstance().apply {
        set(Calendar.HOUR_OF_DAY, 0)
        set(Calendar.MINUTE, 0)
        set(Calendar.SECOND, 0)
        set(Calendar.MILLISECOND, 0)
        add(Calendar.DAY_OF_YEAR, 1) // tomorrow 00:00
    }

    // Now it's safe to use exact alarms
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC, calendar.timeInMillis, pendingIntent)
    } else {
        alarmManager.setExact(AlarmManager.RTC, calendar.timeInMillis, pendingIntent)
    }
}