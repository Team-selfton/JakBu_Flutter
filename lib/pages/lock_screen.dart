import 'package:flutter/material.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import '../services/widget_service.dart';

enum Priority { low, medium, high }

class Todo {
  final String id;
  final String text;
  final Priority priority;
  bool completed;

  Todo({
    required this.id,
    required this.text,
    required this.priority,
    this.completed = false,
  });
}

class LockScreen extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onNotificationClick;

  const LockScreen({
    super.key,
    required this.onBack,
    required this.onNotificationClick,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  String _time = '';
  String _date = '';
  Timer? _timer;
  final List<Todo> _todos = [];
  final TextEditingController _todoController = TextEditingController();
  Priority _selectedPriority = Priority.medium;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _todoController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final now = DateTime.now();
    final weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[now.weekday % 7];

    setState(() {
      _time = DateFormat('HH:mm').format(now);
      _date = '${now.month.toString().padLeft(2, '0')}. ${now.day.toString().padLeft(2, '0')}. ($weekday)';
    });
  }

  void _addTodo() {
    if (_todoController.text.trim().isNotEmpty) {
      setState(() {
        _todos.add(Todo(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: _todoController.text.trim(),
          priority: _selectedPriority,
        ));
        _todoController.clear();
      });
      _updateWidget();
    }
  }

  void _toggleTodo(String id) {
    setState(() {
      final todo = _todos.firstWhere((t) => t.id == id);
      todo.completed = !todo.completed;
    });
    _updateWidget();
  }

  void _deleteTodo(String id) {
    setState(() {
      _todos.removeWhere((t) => t.id == id);
    });
    _updateWidget();
  }

  void _updateWidget() {
    final activeTodos = _todos.where((todo) => !todo.completed).length;
    WidgetService.updateWidget(todoCount: activeTodos);
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade500;
      case Priority.medium:
        return Colors.orange.shade500;
      case Priority.low:
        return Colors.green.shade500;
    }
  }

  String _getPriorityLabel(Priority priority) {
    switch (priority) {
      case Priority.high:
        return '높음';
      case Priority.medium:
        return '중간';
      case Priority.low:
        return '낮음';
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
              Color(0xFF151f2d),
              Color(0xFF0a0e13),
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
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 2,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton('잠금화면 위젯', true),
                    ),
                    Expanded(
                      child: _buildTabButton('앱 실행', false),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // Time and Date
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _time,
                                style: const TextStyle(
                                  fontSize: 80,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.0,
                                  letterSpacing: -2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.white12,
                                      blurRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _date,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              _buildDot(),
                              const SizedBox(width: 8),
                              _buildDot(),
                              const SizedBox(width: 8),
                              _buildDot(),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 48),

                      // Todo Notification Card
                      GestureDetector(
                        onTap: widget.onNotificationClick,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xFF4a7bc0),
                                Color(0xFF4470b3),
                                Color(0xFF3d66a3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4a7bc0).withValues(alpha: 0.4),
                                blurRadius: 32,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header
                              Row(
                                children: [
                                  const Text(
                                    '👊',
                                    style: TextStyle(
                                      fontSize: 60,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 8,
                                          offset: Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'JakBu',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '오늘의 할일',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.95),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 20),

                              Text(
                                '할일을 추가해보세요',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.95),
                                ),
                              ),

                              const SizedBox(height: 12),

                              // Add Todo Input
                              Material(
                                color: Colors.transparent,
                                child: TextField(
                                  controller: _todoController,
                                  onSubmitted: (_) => _addTodo(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: '새 할일...',
                                    hintStyle: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withValues(alpha: 0.15),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.25),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.4),
                                        width: 2,
                                      ),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 14,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Priority Selector and Add Button
                              Row(
                                children: [
                                  Expanded(
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: Colors.white.withValues(alpha: 0.25),
                                          ),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<Priority>(
                                            value: _selectedPriority,
                                            isExpanded: true,
                                            dropdownColor: const Color(0xFF4a7bc0),
                                            padding: const EdgeInsets.symmetric(horizontal: 16),
                                            borderRadius: BorderRadius.circular(16),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            items: Priority.values.map((priority) {
                                              return DropdownMenuItem(
                                                value: priority,
                                                child: Text(_getPriorityLabel(priority)),
                                              );
                                            }).toList(),
                                            onChanged: (Priority? value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedPriority = value;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: _addTodo,
                                      borderRadius: BorderRadius.circular(16),
                                      child: Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(16),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                        child: const Icon(
                                          Icons.add,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Todo List
                              if (_todos.isNotEmpty) ...[
                                const SizedBox(height: 16),
                                ..._todos.take(3).map((todo) => _buildTodoItem(todo)),
                                if (_todos.length > 3)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      '외 ${_todos.length - 3}개 더...',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Bottom Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildActionButton('👊', null),
                          const SizedBox(width: 24),
                          _buildActionButton(null, Icons.grid_view_rounded),
                          const SizedBox(width: 24),
                          _buildActionButton(null, Icons.settings),
                        ],
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String text, bool isActive) {
    return GestureDetector(
      onTap: isActive ? null : widget.onBack,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isActive
              ? const Border(
                  bottom: BorderSide(
                    color: Color(0xFF5b8dd5),
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
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTodoItem(Todo todo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: todo.completed
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _toggleTodo(todo.id),
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: todo.completed
                    ? _getPriorityColor(todo.priority)
                    : Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: todo.completed
                    ? null
                    : Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 2,
                      ),
              ),
              child: todo.completed
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 12,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo.text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                decoration: todo.completed ? TextDecoration.lineThrough : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _getPriorityColor(todo.priority),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => _deleteTodo(todo.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                color: Colors.red.shade400,
                size: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String? emoji, IconData? icon) {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(34),
          child: Center(
            child: emoji != null
                ? Text(
                    emoji,
                    style: const TextStyle(fontSize: 36),
                  )
                : Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
          ),
        ),
      ),
    );
  }
}
