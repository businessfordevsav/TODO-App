import 'package:flutter/foundation.dart';
import '../../data/models/todo_model.dart';
import '../../data/repositories/todo_repository.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';

enum TodoStatus { initial, loading, success, error }

class TodoProvider extends ChangeNotifier {
  final TodoRepository _repository;

  TodoProvider(this._repository);

  List<TodoItem> _todos = [];
  TodoStatus _status = TodoStatus.initial;
  String? _errorMessage;

  List<TodoItem> get todos => _todos;
  TodoStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == TodoStatus.loading;
  bool get hasError => _status == TodoStatus.error;

  List<TodoItem> get completedTodos =>
      _todos.where((todo) => todo.isCompleted).toList();

  List<TodoItem> get activeTodos =>
      _todos.where((todo) => !todo.isCompleted).toList();

  int get completedCount => completedTodos.length;
  int get activeCount => activeTodos.length;
  int get totalCount => _todos.length;

  Future<void> loadTodos() async {
    AppLogger.state('TodoProvider', 'loadTodos');
    _status = TodoStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _todos = await _repository.getTodos();
      AppLogger.state(
        'TodoProvider',
        'loadTodos',
        data: 'Loaded ${_todos.length} todos',
      );
      _status = TodoStatus.success;
    } on NetworkException catch (e) {
      _errorMessage = e.toString();
      _status = TodoStatus.error;
    } on ApiException catch (e) {
      _errorMessage = e.toString();
      _status = TodoStatus.error;
    } catch (e) {
      _errorMessage = 'Unexpected error: $e';
      _status = TodoStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<bool> addTodo(String title) async {
    AppLogger.state('TodoProvider', 'addTodo', data: title);
    if (title.trim().isEmpty) {
      _errorMessage = 'Todo title cannot be empty';
      notifyListeners();
      return false;
    }

    try {
      final newTodo = TodoItem(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title.trim(),
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: 1,
      );

      final createdTodo = await _repository.createTodo(newTodo);
      _todos.insert(0, createdTodo);
      _errorMessage = null;
      notifyListeners();
      return true;
    } on NetworkException catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Failed to add todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTodoStatus(int id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return false;

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(
      isCompleted: !todo.isCompleted,
      updatedAt: DateTime.now(),
    );

    // Optimistic update
    _todos[index] = updatedTodo;
    notifyListeners();

    try {
      await _repository.updateTodo(updatedTodo);
      return true;
    } catch (e) {
      // Revert on failure
      _todos[index] = todo;
      _errorMessage = 'Failed to update todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTodoTitle(int id, String newTitle) async {
    if (newTitle.trim().isEmpty) {
      _errorMessage = 'Todo title cannot be empty';
      notifyListeners();
      return false;
    }

    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return false;

    final todo = _todos[index];
    final updatedTodo = todo.copyWith(
      title: newTitle.trim(),
      updatedAt: DateTime.now(),
    );

    _todos[index] = updatedTodo;
    notifyListeners();

    try {
      await _repository.updateTodo(updatedTodo);
      return true;
    } catch (e) {
      _todos[index] = todo;
      _errorMessage = 'Failed to update todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTodo(int id) async {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index == -1) return false;

    final removedTodo = _todos.removeAt(index);
    notifyListeners();

    try {
      await _repository.deleteTodo(id);
      return true;
    } catch (e) {
      // Revert on failure
      _todos.insert(index, removedTodo);
      _errorMessage = 'Failed to delete todo: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> syncData() async {
    try {
      await _repository.syncPendingChanges();
      await loadTodos(); // Refresh after sync
    } catch (e) {
      _errorMessage = 'Sync failed: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
