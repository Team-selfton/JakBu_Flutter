import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
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

      // 플랫폼별 위젯 업데이트
      if (!kIsWeb && Platform.isAndroid) {
        await HomeWidget.updateWidget(androidName: 'JakbuWidget');
      } else if (!kIsWeb && Platform.isIOS) {
        await HomeWidget.updateWidget(iOSName: 'JakbuLiveActivity');
      }
    } catch (e) {
      debugPrint('위젯 업데이트 실패: $e');
    }
  }

  // 위젯 초기화
  static Future<void> initWidget() async {
    try {
      // iOS에서만 App Group ID 설정
      if (!kIsWeb && Platform.isIOS) {
        await HomeWidget.setAppGroupId('group.ahyeonlee.jakbuFlutter');
        debugPrint('✅ iOS 위젯 초기화 완료');
      }
    } catch (e) {
      debugPrint('위젯 초기화 실패: $e');
    }
  }
}
