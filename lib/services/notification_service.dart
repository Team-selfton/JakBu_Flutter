import 'package:dio/dio.dart';
import '../models/notification_models.dart';
import 'api_client.dart';

class NotificationService {
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<void> saveFcmToken(String fcmToken) async {
    try {
      await _apiClient.dio.post(
        '/notification/token',
        data: FcmTokenRequest(fcmToken: fcmToken).toJson(),
      );
    } on DioException catch (e) {
      throw Exception('Failed to save FCM token: ${e.message}');
    }
  }

  Future<NotificationSetting> saveNotificationSetting(
      NotificationSettingRequest request) async {
    try {
      final response = await _apiClient.dio.post(
        '/notification/setting',
        data: request.toJson(),
      );
      return NotificationSetting.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception('Failed to save notification setting: ${e.message}');
    }
  }

  Future<NotificationSetting> getNotificationSetting() async {
    try {
      final response = await _apiClient.dio.get('/notification/setting');
      return NotificationSetting.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw Exception('Notification setting not found');
      }
      throw Exception('Failed to get notification setting: ${e.message}');
    }
  }
}
