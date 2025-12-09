import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_client.dart';
import '../services/todo_service.dart';
import '../services/live_activity_service.dart';
import '../services/widget_service.dart';
import '../models/todo_models.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  List<TodoModel> _todos = [];
  List<TodoModel> _activeTodos = [];
  List<TodoModel> _completedTodos = [];
  final _activeListKey = GlobalKey<AnimatedListState>();
  final _completedListKey = GlobalKey<AnimatedListState>();

  final TextEditingController _textController = TextEditingController();
  late final TodoService _todoService;
  final LiveActivityService _liveActivityService = LiveActivityService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _todoService = TodoService(ApiClient());
    _loadTodayTodos();
    // _initializeLiveActivity(); // LiveActivity 비활성화
    _initializeWidget();
  }

  // Future<void> _initializeLiveActivity() async {
  //   await _liveActivityService.getAllActivities();
  // }

  Future<void> _initializeWidget() async {
    await WidgetService.initWidget();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _loadTodayTodos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final todos = await _todoService.getTodayTodos();
      if (mounted) {
        setState(() {
          _todos = todos;
          _activeTodos =
              _todos.where((todo) => todo.status == TodoStatus.todo).toList();
          _completedTodos =
              _todos.where((todo) => todo.status == TodoStatus.done).toList();
        });
        // Live Activity 업데이트
        // await _liveActivityService.updateActivity(_todos); // LiveActivity 비활성화
        // 위젯 업데이트
        await WidgetService.updateWidget(_todos);
      }
    } catch (e) {
      if (mounted) {
        _showError('할일 목록을 불러오는데 실패했습니다: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _addTodo() async {
    if (_textController.text.trim().isEmpty) return;

    try {
      final newTodo = await _todoService.createTodo(
        CreateTodoRequest(
          title: _textController.text.trim(),
          date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
        ),
      );

      if (mounted) {
        _todos.add(newTodo);
        _activeTodos.insert(0, newTodo);
        _activeListKey.currentState?.insertItem(0);
        
        setState(() {
          _textController.clear();
        });

        // Live Activity 업데이트
        // await _liveActivityService.updateActivity(_todos); // LiveActivity 비활성화
        // 위젯 업데이트
        await WidgetService.updateWidget(_todos);
      }
    } catch (e) {
      if (mounted) {
        _showError('할일 추가에 실패했습니다: ${e.toString()}');
      }
    }
  }

  Future<void> _toggleTodo(int id) async {
    final todoIndex = _todos.indexWhere((t) => t.id == id);
    if (todoIndex == -1) return;

    final todo = _todos[todoIndex];
    final isCompleted = todo.status == TodoStatus.done;

    // Determine source and destination
    final sourceList = isCompleted ? _completedTodos : _activeTodos;
    final destinationList = isCompleted ? _activeTodos : _completedTodos;
    final sourceKey = isCompleted ? _completedListKey : _activeListKey;
    final destinationKey = isCompleted ? _activeListKey : _completedListKey;

    final indexInSource = sourceList.indexWhere((t) => t.id == id);
    if (indexInSource == -1) return; // Should not happen

    // --- Optimistic UI Update ---

    // 1. Remove from source list (UI)
    final removedItem = sourceList.removeAt(indexInSource);
    sourceKey.currentState?.removeItem(
      indexInSource,
      (context, animation) =>
          _buildAnimatedTodoItem(removedItem, isCompleted, animation),
      duration: const Duration(milliseconds: 300),
    );

    // 2. Create the updated item for the destination list
    final updatedItem = TodoModel(
      id: removedItem.id,
      title: removedItem.title,
      date: removedItem.date,
      status: isCompleted ? TodoStatus.todo : TodoStatus.done,
    );

    // 3. Add to destination list (UI)
    destinationList.insert(0, updatedItem);
    destinationKey.currentState?.insertItem(0,
        duration: const Duration(milliseconds: 300));

    // 4. Update the master list
    _todos[todoIndex] = updatedItem;

    // Trigger updates for widgets
    // await _liveActivityService.updateActivity(_todos); // LiveActivity 비활성화
    await WidgetService.updateWidget(_todos);

    // --- API Call ---
    try {
      // 5. Call the API
      await _todoService.toggleTodoStatus(id);
    } catch (e) {
      if (mounted) {
        _showError('상태 변경 동기화 실패: ${e.toString()}');
        // --- Revert UI on failure ---
        // For simplicity, we reload the state from the server.
        await _loadTodayTodos();
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5b8dd5),
        ),
      );
    }

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

          // Add todo section
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '오늘의 할일을 추가해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _textController,
                  onSubmitted: (_) => _addTodo(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: '새 할일...',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF5b8dd5), Color(0xFF4a7bc0)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF5b8dd5).withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _addTodo,
                      borderRadius: BorderRadius.circular(16),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              '추가하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active todos
          if (_activeTodos.isNotEmpty) ...[
            const SizedBox(height: 20),
            _buildTodoSection('Todo', _activeTodos, false),
          ],

          // Completed todos
          const SizedBox(height: 16),
          _buildTodoSection('Done', _completedTodos, true),

          // Empty state
          if (_todos.isEmpty) ...[
            const SizedBox(height: 20),
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
                    '오늘의 할일을 추가해보세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '꾸준함이 습관을 만들고,',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                  Text(
                    '습관이 인생을 바꿉니다.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Bottom emoji
          const SizedBox(height: 32),
          const Center(
            child: Text(
              '👊',
              style: TextStyle(fontSize: 64),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTodoSection(String title, List<TodoModel> todos, bool isCompleted) {
    final listKey = isCompleted ? _completedListKey : _activeListKey;

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
          todos.isEmpty
              ? _buildEmptyListPlaceholder(isCompleted)
              : AnimatedList(
                  key: listKey,
                  initialItemCount: todos.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index, animation) {
                    // Check for index out of bounds
                    if (index >= todos.length) {
                      return const SizedBox.shrink();
                    }
                    final todo = todos[index];
                    return _buildAnimatedTodoItem(todo, isCompleted, animation);
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildEmptyListPlaceholder(bool isCompleted) {
    final message = isCompleted
        ? '아직 완료된 할일이 없어요.\n할일을 완료해 보세요!'
        : '오늘의 할일이 없어요.\n새로운 할일을 추가해 보세요!';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildAnimatedTodoItem(
      TodoModel todo, bool isCompleted, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SizeTransition(
        sizeFactor: CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        ),
        child: _buildTodoItem(todo, isCompleted),
      ),
    );
  }

  Widget _buildTodoItem(TodoModel todo, bool isCompleted) {
    return Container(
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
          GestureDetector(
            onTap: () => _toggleTodo(todo.id),
            child: Container(
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
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              todo.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                decoration:
                    isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
