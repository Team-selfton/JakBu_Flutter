import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';
import '../services/todo_service.dart';
import '../models/todo_models.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  int? _selectedDate;
  List<TodoModel> _todos = [];
  DateTime _currentDate = DateTime.now();
  late final TodoService _todoService;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _todoService = TodoService(ApiClient());
    // 오늘 날짜를 자동으로 선택하고 할일 조회
    _selectedDate = DateTime.now().day;
    _loadTodosByDate(DateTime.now());
  }

  String get _currentMonth {
    return '${_currentDate.year}년 ${_currentDate.month}월';
  }

  int get _daysInMonth {
    return DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
  }

  void _previousMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      _selectedDate = null;
      _todos = [];
    });
  }

  void _nextMonth() {
    setState(() {
      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      _selectedDate = null;
      _todos = [];
    });
  }

  Future<void> _loadTodosByDate(DateTime date) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date);
      final todos = await _todoService.getTodosByDate(dateString);
      if (mounted) {
        setState(() {
          _todos = todos;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('할일 목록을 불러오는데 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleTodo(int id) async {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex == -1) return;

    try {
      final updatedTodo = await _todoService.toggleTodoStatus(id);
      if (mounted) {
        setState(() {
          _todos[todoIndex] = updatedTodo;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('할일 상태 변경에 실패했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeTodos = _todos.where((todo) => todo.status == TodoStatus.TODO).toList();
    final completedTodos = _todos.where((todo) => todo.status == TodoStatus.DONE).toList();
    final now = DateTime.now();
    final todayDate = now.day;
    final isCurrentMonth = _currentDate.year == now.year && _currentDate.month == now.month;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          const SizedBox(height: 24),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6b9bd8), Color(0xFF5b8dd5)],
            ).createShader(bounds),
            child: const Text(
              'JakBu',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            '작심삼일 부수기',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 20),

          // Calendar section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              children: [
                // Calendar header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '일정',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _previousMonth,
                          icon: Icon(
                            Icons.chevron_left,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                        SizedBox(
                          width: 90,
                          child: Text(
                            _currentMonth,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _nextMonth,
                          icon: Icon(
                            Icons.chevron_right,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          padding: const EdgeInsets.all(4),
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Days of week
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: ['일', '월', '화', '수', '목', '금', '토']
                      .map((day) => SizedBox(
                            width: 32,
                            child: Text(
                              day,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),

                // Calendar grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _daysInMonth,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = _selectedDate == day;
                    final isToday = isCurrentMonth && day == todayDate;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = day;
                        });
                        final selectedDate = DateTime(_currentDate.year, _currentDate.month, day);
                        _loadTodosByDate(selectedDate);
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: isSelected
                                  ? const LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF5b8dd5),
                                        Color(0xFF4a7bc0),
                                      ],
                                    )
                                  : null,
                              color: isSelected
                                  ? null
                                  : isToday
                                      ? Colors.white.withOpacity(0.2)
                                      : null,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '$day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isSelected || isToday
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ),
                          ),
                          if (isToday && completedTodos.isNotEmpty)
                            Positioned(
                              top: -4,
                              right: -4,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFF1e2a3f),
                                    width: 1,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Selected date content
          if (_selectedDate != null) ...[
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF5b8dd5),
                ),
              )
            else ...[
              if (activeTodos.isNotEmpty)
                _buildTodoSection('$_selectedDate일 Todo', activeTodos, false),
              if (completedTodos.isNotEmpty) ...[
                const SizedBox(height: 16),
                _buildTodoSection('$_selectedDate일 Done', completedTodos, true),
              ],
              if (activeTodos.isEmpty && completedTodos.isEmpty)
                _buildEmptyState('이 날짜에 할일이 없습니다'),
            ],
          ],

          // No date selected
          if (_selectedDate == null) ...[
            const SizedBox(height: 20),
            if (activeTodos.isNotEmpty || completedTodos.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '📅',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '날짜를 선택해보세요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '그날의 할일을 확인할 수 있어요',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            if (activeTodos.isEmpty && completedTodos.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.05),
                      Colors.white.withOpacity(0.02),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '👊',
                      style: TextStyle(fontSize: 48),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '아직 할일이 없어요',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '할일을 추가하면 여기에 기록됩니다',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTodoSection(String title, List<TodoModel> todos, bool isCompleted) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCompleted
              ? [
                  Colors.white.withOpacity(0.05),
                  Colors.white.withOpacity(0.02),
                ]
              : [
                  Colors.white.withOpacity(0.1),
                  Colors.white.withOpacity(0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCompleted
                  ? Colors.white.withOpacity(0.7)
                  : Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          ...todos.map((todo) => _buildTodoItem(todo, isCompleted)).toList(),
        ],
      ),
    );
  }

  Widget _buildTodoItem(TodoModel todo, bool isCompleted) {
    return GestureDetector(
      onTap: () => _toggleTodo(todo.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF5b8dd5)
                    : Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: isCompleted
                    ? null
                    : Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 2,
                      ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                todo.title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.05),
            Colors.white.withOpacity(0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
        ),
      ),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
