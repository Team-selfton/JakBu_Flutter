import 'package:flutter/material.dart';
import 'todo_page.dart';
import 'calendar_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _activeTab = 0; // 0: todo, 1: calendar

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
                      color: Colors.white.withOpacity(0.1),
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
            color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
