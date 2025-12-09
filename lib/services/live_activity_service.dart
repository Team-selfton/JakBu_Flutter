import 'package:live_activities/live_activities.dart';
import '../models/todo_models.dart';

class LiveActivityService {
  final _liveActivitiesPlugin = LiveActivities();
  String? _activityId;

  // Live Activity 시작
  Future<void> startTodoActivity(List<TodoModel> todos) async {
    if (todos.isEmpty) {
      await endActivity();
      return;
    }

    final activityData = _buildActivityData(todos);

    try {
      // 이미 활성화된 Activity가 있으면 업데이트
      if (_activityId != null) {
        await updateActivity(todos);
        return;
      }

      // 새로운 Activity 시작
      _activityId = await _liveActivitiesPlugin.createActivity(activityData);
    } catch (e) {
    }
  }

  // Live Activity 업데이트
  Future<void> updateActivity(List<TodoModel> todos) async {
    if (_activityId == null) {
      await startTodoActivity(todos);
      return;
    }

    if (todos.isEmpty) {
      await endActivity();
      return;
    }

    final activityData = _buildActivityData(todos);

    try {
      await _liveActivitiesPlugin.updateActivity(
        _activityId!,
        activityData,
      );
    } catch (e) {
      // Activity가 종료되었을 수 있으므로 다시 시작
      _activityId = null;
      await startTodoActivity(todos);
    }
  }

  // Live Activity 종료
  Future<void> endActivity() async {
    if (_activityId == null) return;

    try {
      await _liveActivitiesPlugin.endActivity(_activityId!);
      _activityId = null;
    } catch (e) {
      _activityId = null;
    }
  }

  // Activity 데이터 빌드
  Map<String, dynamic> _buildActivityData(List<TodoModel> todos) {
    final completedCount = todos.where((t) => t.status == TodoStatus.done).length;

    return {
      'startDate': DateTime.now().toIso8601String(),
      'todos': todos.map((todo) => {
        'id': todo.id,
        'title': todo.title,
        'isDone': todo.status == TodoStatus.done,
      }).toList(),
      'totalCount': todos.length,
      'completedCount': completedCount,
    };
  }

  // 모든 활성화된 Activity 가져오기
  Future<void> getAllActivities() async {
    try {
      final activities = await _liveActivitiesPlugin.getAllActivities();

      if (activities.isNotEmpty) {
        _activityId = activities.keys.first;
      }
    } catch (e) {
    }
  }

  // Activity 상태 확인
  bool get isActivityActive => _activityId != null;
}
