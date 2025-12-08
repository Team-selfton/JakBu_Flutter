import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<AuthResponse> signup(SignupRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/signup',
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception(
            e.response?.data['message'] ?? 'Account ID already exists');
      }
      throw Exception('Failed to signup: ${e.message}');
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/login',
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveToken(authResponse.token);
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid account ID or password');
      }
      throw Exception('Failed to login: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _apiClient.deleteToken();
  }
}
