import 'package:flutter/material.dart';
import '../services/api_client.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onStart;
  final VoidCallback onAutoLogin;

  const SplashScreen({
    super.key,
    required this.onStart,
    required this.onAutoLogin,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    await Future.delayed(const Duration(seconds: 1)); // 스플래시 최소 표시 시간

    final hasToken = await _apiClient.hasToken();
    if (mounted) {
      setState(() {
        _isChecking = false;
      });

      if (hasToken) {
        // 토큰이 있으면 자동 로그인
        widget.onAutoLogin();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1e2a3f),
              Color(0xFF1a2332),
              Color(0xFF0f1520),
            ],
          ),
        ),
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Emoji with animation
              const Text(
                '👊',
                style: TextStyle(fontSize: 120),
              ),
              const SizedBox(height: 32),
              // Title
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Color(0xFF6b9bd8), Color(0xFF5b8dd5)],
                ).createShader(bounds),
                child: const Text(
                  'JakBu',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Subtitle
              const Text(
                '작심삼일 부수기',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 48),
              // Description
              Column(
                children: [
                  Text(
                    '오늘의 할일부터 시작해보세요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '꾸준함이 습관을 만들고,',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '습관이 인생을 바꿉니다.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Start button or loading
              if (_isChecking)
                const CircularProgressIndicator(
                  color: Color(0xFF5b8dd5),
                )
              else
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5b8dd5), Color(0xFF4a7bc0)],
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5b8dd5).withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onStart,
                      borderRadius: BorderRadius.circular(28),
                      child: const Center(
                        child: Text(
                          '시작하기',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
