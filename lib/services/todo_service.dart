import 'package:dio/dio.dart';
import '../models/todo_models.dart';
import 'api_client.dart';

class TodoService {
  final ApiClient _apiClient;

  TodoService(this._apiClient);

  Future<TodoModel> createTodo(CreateTodoRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/todo',
        data: request.toJson(),
      );
      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to create todo: ${e.message}');
    }
  }

  Future<List<TodoModel>> getTodayTodos() async {
    try {
      final response = await _apiClient.dio.get('/todo/today');
      return (response.data as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to get today todos: ${e.message}');
    }
  }

  Future<List<TodoModel>> getTodosByDate(String date) async {
    try {
      final response = await _apiClient.dio.get(
        '/todo/date',
        queryParameters: {'date': date},
      );
      return (response.data as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();
    } on DioException catch (e) {
      throw Exception('Failed to get todos by date: ${e.message}');
    }
  }

  Future<TodoModel> markTodoDone(int todoId) async {
    try {
      final response = await _apiClient.dio.post('/todo/$todoId/done');
      return TodoModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(e.response?.data['message'] ?? 'Todo not found');
      }
      throw Exception('Failed to mark todo done: ${e.message}');
    }
  }
}
