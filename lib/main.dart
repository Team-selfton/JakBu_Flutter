import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jakbu_flutter/services/auth_service.dart';
import 'firebase_options.dart';
import 'pages/splash_screen.dart';
import 'pages/auth_screen.dart';
import 'pages/main_app.dart';
import 'core/globals.dart';
import 'services/local_notification_service.dart';
import 'services/api_client.dart';
import 'services/notification_service.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeServices();
  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  debugPrint('🔄 서비스 초기화 시작...');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('✅ Firebase 초기화 완료');

  localNotificationService = LocalNotificationService();
  await localNotificationService.init();

  // 매일 아침 8시 알림 스케줄링
  await localNotificationService.scheduleDailyMorningNotification(
    title: '작부 알림',
    body: '오늘의 할 일을 확인해보세요!',
  );

  apiClient = ApiClient();
  authService = AuthService(apiClient);
  notificationService = NotificationService(apiClient);
  fcmService = FCMService(notificationService, localNotificationService);
  await fcmService.initialize();

  debugPrint('✅ 모든 서비스 초기화 완료');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

enum AppScreen { splash, auth, main }

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  AppScreen _currentScreen = AppScreen.splash;
  DateTime? _pausedTime;
  static const _resetDuration = Duration(minutes: 5); // 5분 이상 백그라운드면 리셋

  @override
  void initState() {
    super.initState();
    // API 인증 실패 시 로그인 화면으로 이동하는 콜백 설정
    onAuthenticationFailed = _onLogout;
    // 앱 라이프사이클 옵저버 등록
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    debugPrint('📱 앱 라이프사이클 변경: $state');

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
        // 앱이 백그라운드로 갈 때 시간 기록
        _pausedTime = DateTime.now();
        debugPrint('📱 앱이 백그라운드로 이동: $_pausedTime');
        break;

      case AppLifecycleState.resumed:
        // 앱이 포그라운드로 돌아올 때
        if (_pausedTime != null) {
          final difference = DateTime.now().difference(_pausedTime!);
          debugPrint('📱 앱이 포그라운드로 복귀 - 백그라운드 시간: ${difference.inSeconds}초');

          // 일정 시간 이상 백그라운드에 있었다면 스플래시로 리셋
          if (difference > _resetDuration) {
            debugPrint('🔄 장시간 백그라운드 - 스플래시로 리셋');
            setState(() {
              _currentScreen = AppScreen.splash;
            });
          }
          _pausedTime = null;
        }
        break;

      case AppLifecycleState.detached:
        debugPrint('📱 앱 종료');
        break;

      case AppLifecycleState.hidden:
        debugPrint('📱 앱 숨김');
        break;
    }
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
