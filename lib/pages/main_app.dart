import 'package:flutter/material.dart';
import 'package:jakbu_flutter/services/api_client.dart';
import 'package:jakbu_flutter/services/auth_service.dart';
import 'package:jakbu_flutter/core/globals.dart';
import 'todo_page.dart';
import 'calendar_page.dart';

class MainApp extends StatefulWidget {
  final VoidCallback onLogout;
  const MainApp({super.key, required this.onLogout});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _activeTab = 0; // 0: todo, 1: calendar
  final AuthService _authService = AuthService(ApiClient());

  void _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('로그아웃'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _authService.logout();
      if (mounted) {
        widget.onLogout();
      }
    }
  }

  void _testNotification() async {
    // 즉시 알림 테스트
    await localNotificationService.showNotification(
      id: 999,
      title: '테스트 알림',
      body: '푸시알림이 정상적으로 작동합니다!',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('테스트 알림이 발송되었습니다'),
          duration: Duration(seconds: 2),
        ),
      );
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
          child: Column(
            children: [
              // Tab navigation
              Container(
                margin: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withAlpha(26),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        '메인',
                        0,
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        '캘린더',
                        1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_active, color: Colors.amber),
                      onPressed: _testNotification,
                      tooltip: '알림 테스트',
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _logout,
                      tooltip: '로그아웃',
                    ),
                  ],
                ),
              ),
              // Page content
              Expanded(
                child: _activeTab == 0
                    ? const TodoPage()
                    : const CalendarPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isActive = _activeTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isActive
              ? Border(
                  bottom: BorderSide(
                    color: const Color(0xFF5b8dd5),
                    width: 4,
                  ),
                )
              : null,
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.white.withAlpha(128),
          ),
        ),
      ),
    );
  }
}
