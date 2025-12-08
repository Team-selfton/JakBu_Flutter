package com.example.jakbu_flutter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import java.text.SimpleDateFormat
import java.util.*

class JakbuWidget : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.jakbu_widget_layout)

    // Update time
    val currentTime = SimpleDateFormat("HH:mm", Locale.getDefault()).format(Date())
    views.setTextViewText(R.id.widget_time, currentTime)

    // Update date
    val currentDate = SimpleDateFormat("MM. dd. (E)", Locale.KOREAN).format(Date())
    views.setTextViewText(R.id.widget_date, currentDate)

    // Update todo count (you'll need to get this from shared preferences)
    val sharedPref = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
    val todoCount = sharedPref.getInt("todo_count", 0)
    views.setTextViewText(R.id.widget_todo_count, "오늘 할일 ${todoCount}개")

    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}
