import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';
import 'services/api_client.dart';
import 'pages/splash_screen.dart';
import 'pages/auth_screen.dart';
import 'services/local_notification_service.dart';
import 'pages/main_app.dart';
import 'core/globals.dart';

// 전역 FCM 서비스 인스턴스
late FCMService fcmService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // runApp()을 호출하기 전에 모든 초기화가 완료되도록 기다립니다.
  await _initializeFirebase();

  // 모든 초기화가 완료된 후 앱 UI를 시작
  runApp(const MyApp());
}

Future<void> _initializeFirebase() async {
  try {
    debugPrint('🔄 Firebase 초기화 시작...');

    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase 초기화 완료');

    // 로컬 알림 서비스 초기화
    final localNotificationService = LocalNotificationService();
    await localNotificationService.init();

    // API 클라이언트 및 서비스 초기화
    final apiClient = ApiClient();
    final notificationService = NotificationService(apiClient);

    // FCM 서비스 초기화
    fcmService = FCMService(notificationService, localNotificationService);
    await fcmService.initialize();

    debugPrint('✅ FCM 초기화 완료');
  } catch (e, stackTrace) {
    debugPrint('❌ Firebase 초기화 실패: $e');
    debugPrint('스택 트레이스: $stackTrace');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppScreen { splash, auth, main }

class _MyAppState extends State<MyApp> {
  AppScreen _currentScreen = AppScreen.splash;

  @override
  void initState() {
    super.initState();
    // API 인증 실패 시 로그인 화면으로 이동하는 콜백 설정
    onAuthenticationFailed = _onLogout;
  }

  void _onStart() {
    setState(() {
      _currentScreen = AppScreen.auth;
    });
  }

  void _onAutoLogin() {
    setState(() {
      _currentScreen = AppScreen.main;
    });
  }

  void _onLoginComplete() {
    setState(() {
      _currentScreen = AppScreen.main;
    });
  }

  void _onLogout() {
    setState(() {
      _currentScreen = AppScreen.auth;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'JakBu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      home: _currentScreen == AppScreen.splash
          ? SplashScreen(
              onStart: _onStart,
              onAutoLogin: _onAutoLogin,
            )
          : _currentScreen == AppScreen.auth
              ? AuthScreen(onLoginComplete: _onLoginComplete)
              : MainApp(onLogout: _onLogout),
    );
  }
}
