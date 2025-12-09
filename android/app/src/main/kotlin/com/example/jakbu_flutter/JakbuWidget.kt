package com.example.jakbu_flutter

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.util.Log
import android.view.View
import android.widget.RemoteViews
import org.json.JSONArray

data class TodoItem(
    val id: Int,
    val title: String,
    val isDone: Boolean
)

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
        Log.d("JakbuWidget", "Widget enabled")
    }

    override fun onDisabled(context: Context) {
        Log.d("JakbuWidget", "Widget disabled")
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    val views = RemoteViews(context.packageName, R.layout.jakbu_widget_layout)

    try {
        // Get todo data from shared preferences
        val sharedPref = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val todosJson = sharedPref.getString("widget_todos", "[]")
        Log.d("JakbuWidget", "Todos JSON: $todosJson")

        val todos = parseTodos(todosJson ?: "[]")
        Log.d("JakbuWidget", "Parsed ${todos.size} todos")

        val totalCount = todos.size
        val completedCount = todos.count { it.isDone }
        val remainingCount = totalCount - completedCount

        // Update count
        views.setTextViewText(R.id.widget_remaining_count, "$remainingCount")

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d("JakbuWidget", "Widget updated successfully")

    } catch (e: Exception) {
        Log.e("JakbuWidget", "Error updating widget", e)

        // 오류 발생 시 기본 상태 표시
        views.setTextViewText(R.id.widget_remaining_count, "ERR")

        appWidgetManager.updateAppWidget(appWidgetId, views)
    }
}

private fun parseTodos(jsonString: String): List<TodoItem> {
    val todos = mutableListOf<TodoItem>()
    try {
        val jsonArray = JSONArray(jsonString)
        for (i in 0 until jsonArray.length()) {
            val jsonObject = jsonArray.getJSONObject(i)
            todos.add(
                TodoItem(
                    id = jsonObject.getInt("id"),
                    title = jsonObject.getString("title"),
                    isDone = jsonObject.getBoolean("isDone")
                )
            )
        }
    } catch (e: Exception) {
        Log.e("JakbuWidget", "Error parsing todos", e)
    }
    return todos
}
