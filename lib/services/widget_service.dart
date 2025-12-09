import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import '../models/todo_models.dart';

class WidgetService {
  // 위젯 데이터 업데이트 (iOS & Android)
  static Future<void> updateWidget(List<TodoModel> todos) async {
    try {
      // Todo 리스트를 JSON으로 변환
      final todosJson = jsonEncode(todos.map((todo) => {
        'id': todo.id,
        'title': todo.title,
        'isDone': todo.status == TodoStatus.done,
      }).toList());

      // Android & iOS용 데이터 저장
      await HomeWidget.saveWidgetData('widget_todos', todosJson);

      // Android 위젯 업데이트
      await HomeWidget.updateWidget(
        androidName: 'JakbuWidget',
      );

      // iOS 위젯 업데이트
      await HomeWidget.updateWidget(
        iOSName: 'JakbuLiveActivity',
      );
    } catch (e) {
      print('Failed to update widget: $e');
    }
  }

  // 위젯 초기화
  static Future<void> initWidget() async {
    try {
      // App Group ID 설정 (iOS용)
      await HomeWidget.setAppGroupId('group.ahyeonlee.jakbuFlutter');
    } catch (e) {
      print('Failed to initialize widget: $e');
    }
  }
}
