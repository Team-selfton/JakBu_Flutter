import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/fcm_service.dart';
import 'services/notification_service.dart';
import 'services/api_client.dart';
import 'pages/splash_screen.dart';
import 'pages/auth_screen.dart';
import 'pages/main_app.dart';

// 전역 FCM 서비스 인스턴스
late FCMService fcmService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 먼저 앱 UI를 시작
  runApp(const MyApp());

  // Firebase 초기화를 백그라운드에서 실행
  _initializeFirebase();
}

Future<void> _initializeFirebase() async {
  try {
    debugPrint('🔄 Firebase 초기화 시작...');

    // Firebase 초기화
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase 초기화 완료');

    // API 클라이언트 및 서비스 초기화
    final apiClient = ApiClient();
    final notificationService = NotificationService(apiClient);

    // FCM 서비스 초기화
    fcmService = FCMService(notificationService);
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
