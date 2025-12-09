import 'package:dio/dio.dart';
import '../models/auth_models.dart';
import 'api_client.dart';
import '../core/globals.dart';

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
      await _apiClient.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      // 로그인 성공 후 FCM 토큰 전송
      await fcmService.sendFcmTokenToServer();
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
      await _apiClient.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      // 로그인 성공 후 FCM 토큰 전송
      await fcmService.sendFcmTokenToServer();
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid account ID or password');
      }
      throw Exception('Failed to login: ${e.message}');
    }
  }

  Future<AuthResponse> refreshToken(RefreshTokenRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/auth/refresh-token',
        data: request.toJson(),
      );
      final authResponse = AuthResponse.fromJson(response.data);
      await _apiClient.saveTokens(
        authResponse.accessToken,
        authResponse.refreshToken,
      );
      return authResponse;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Invalid refresh token');
      }
      throw Exception('Failed to refresh token: ${e.message}');
    }
  }

  Future<void> logout() async {
    await _apiClient.deleteToken();
  }
}
