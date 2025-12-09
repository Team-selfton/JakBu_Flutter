import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';
import '../services/fcm_service.dart';
import '../services/local_notification_service.dart';

// 전역 서비스 인스턴스
late ApiClient apiClient;
late AuthService authService;
late NotificationService notificationService;
late FCMService fcmService;
late LocalNotificationService localNotificationService;


// 전역 Navigator 키 (API 에러 시 로그인 화면으로 이동하기 위해 사용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// 인증 실패 시 호출될 콜백 (api_client에서 UI 위젯을 직접 import하지 않기 위해 사용)
void Function()? onAuthenticationFailed;