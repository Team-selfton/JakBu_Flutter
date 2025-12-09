import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'notification_service.dart';

// 백그라운드 메시지 핸들러 (최상위 함수여야 함)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('백그라운드 메시지 수신: ${message.messageId}');
  debugPrint('제목: ${message.notification?.title}');
  debugPrint('내용: ${message.notification?.body}');
  debugPrint('데이터: ${message.data}');
}

class FCMService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService;
  String? _fcmToken;

  FCMService(this._notificationService);

  String? get fcmToken => _fcmToken;

  /// FCM 초기화
  Future<void> initialize() async {
    try {
      // 알림 권한 요청
      await _requestPermission();

      // FCM 토큰 가져오기
      await _getToken();

      // 백그라운드 메시지 핸들러 설정
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);

      // 포그라운드 메시지 리스너
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 앱이 백그라운드에서 알림 클릭으로 열렸을 때
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // 앱이 종료된 상태에서 알림 클릭으로 열렸을 때
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // 토큰 갱신 리스너
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('FCM 토큰 갱신: $newToken');
        _fcmToken = newToken;
        _saveTokenToServer(newToken);
      });

      debugPrint('✅ FCM 초기화 완료');
    } catch (e) {
      debugPrint('❌ FCM 초기화 실패: $e');
    }
  }

  /// 알림 권한 요청
  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ 알림 권한 허용됨');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('⚠️ 임시 알림 권한');
      } else {
        debugPrint('❌ 알림 권한 거부됨');
      }
    } catch (e) {
      debugPrint('❌ 알림 권한 요청 실패: $e');
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> _getToken() async {
    try {
      // iOS의 경우 APNs 토큰을 먼저 가져와야 할 수 있습니다.
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        debugPrint('⏳ iOS APNs 토큰 요청 중...');
        final apnsToken = await _firebaseMessaging.getAPNSToken();
        if (apnsToken == null) {
          debugPrint('⚠️ APNs 토큰을 즉시 가져올 수 없습니다. onTokenRefresh 스트림이 토큰을 처리할 때까지 기다립니다.');
          // onTokenRefresh가 나중에 호출될 것이므로 여기서 getToken()을 호출하지 않습니다.
          return null;
        }
        debugPrint('✅ APNs 토큰 수신 완료.');
      }

      _fcmToken = await _firebaseMessaging.getToken();
      debugPrint('📱 FCM 토큰: $_fcmToken');

      if (_fcmToken != null) {
        await _saveTokenToServer(_fcmToken!);
      }

      return _fcmToken;
    } catch (e) {
      debugPrint('❌ FCM 토큰 가져오기 실패: $e');
      // 토큰을 지금 가져오지 못해도 나중에 onTokenRefresh로 받을 수 있음
      debugPrint('ℹ️  토큰은 나중에 onTokenRefresh를 통해 받을 수 있습니다');
      return null;
    }
  }

  /// 서버에 FCM 토큰 저장
  Future<void> _saveTokenToServer(String token) async {
    try {
      await _notificationService.saveFcmToken(token);
      debugPrint('✅ FCM 토큰 서버 저장 완료');
    } catch (e) {
      debugPrint('❌ FCM 토큰 서버 저장 실패: $e');
    }
  }

  /// 포그라운드 메시지 처리
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('📬 포그라운드 메시지 수신: ${message.messageId}');
    debugPrint('제목: ${message.notification?.title}');
    debugPrint('내용: ${message.notification?.body}');
    debugPrint('데이터: ${message.data}');

    // TODO: 로컬 알림 표시 또는 UI 업데이트
  }

  /// 백그라운드에서 알림 클릭으로 앱 열림 처리
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('🔔 백그라운드 알림 클릭: ${message.messageId}');
    debugPrint('데이터: ${message.data}');

    // TODO: 특정 화면으로 네비게이션
  }

  /// FCM 토큰 수동 새로고침
  Future<String?> refreshToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      return await _getToken();
    } catch (e) {
      debugPrint('❌ FCM 토큰 새로고침 실패: $e');
      return null;
    }
  }

  /// 특정 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('✅ 토픽 구독: $topic');
    } catch (e) {
      debugPrint('❌ 토픽 구독 실패: $e');
    }
  }

  /// 특정 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('✅ 토픽 구독 해제: $topic');
    } catch (e) {
      debugPrint('❌ 토픽 구독 해제 실패: $e');
    }
  }
}
