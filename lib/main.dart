import 'package:flutter/material.dart';
import 'pages/splash_screen.dart';
import 'pages/auth_screen.dart';
import 'pages/main_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
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
              : const MainApp(),
    );
  }
}
