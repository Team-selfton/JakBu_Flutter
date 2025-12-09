package com.example.jakbu_flutter

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
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

        // Update counts
        views.setTextViewText(R.id.widget_remaining_count, "$remainingCount")
        views.setTextViewText(R.id.widget_total_count, " / $totalCount")

        // Show/hide based on todo count
        if (todos.isEmpty()) {
            views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
            views.setViewVisibility(R.id.todo_item_1, View.GONE)
            views.setViewVisibility(R.id.todo_item_2, View.GONE)
            views.setViewVisibility(R.id.widget_more_text, View.GONE)
        } else {
            views.setViewVisibility(R.id.widget_empty_state, View.GONE)

            // Show first todo
            if (todos.isNotEmpty()) {
                val todo1 = todos[0]
                val text1 = if (todo1.isDone) "✓ ${todo1.title}" else "○ ${todo1.title}"
                views.setTextViewText(R.id.todo_item_1, text1)
                views.setViewVisibility(R.id.todo_item_1, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.todo_item_1, View.GONE)
            }

            // Show second todo
            if (todos.size > 1) {
                val todo2 = todos[1]
                val text2 = if (todo2.isDone) "✓ ${todo2.title}" else "○ ${todo2.title}"
                views.setTextViewText(R.id.todo_item_2, text2)
                views.setViewVisibility(R.id.todo_item_2, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.todo_item_2, View.GONE)
            }

            // Show "more" text if there are more than 2 todos
            if (todos.size > 2) {
                views.setTextViewText(R.id.widget_more_text, "+${todos.size - 2}개 더")
                views.setViewVisibility(R.id.widget_more_text, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_more_text, View.GONE)
            }
        }

        // Set up the intent to launch the app when the button is clicked
        val intent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        val pendingIntent = PendingIntent.getActivity(
            context,
            0,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        views.setOnClickPendingIntent(R.id.widget_add_button, pendingIntent)

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views)
        Log.d("JakbuWidget", "Widget updated successfully")

    } catch (e: Exception) {
        Log.e("JakbuWidget", "Error updating widget", e)

        // 오류 발생 시 기본 상태 표시
        views.setTextViewText(R.id.widget_remaining_count, "ERR")
        views.setTextViewText(R.id.widget_total_count, " / ERR")

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
