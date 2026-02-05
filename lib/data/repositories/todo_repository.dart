import 'package:connectivity_plus/connectivity_plus.dart';
import '../local/database_service.dart';
import '../remote/todo_api_service.dart';
import '../models/todo_model.dart';
import '../../core/utils/logger.dart';

class TodoRepository {
  final TodoApiService _apiService;
  final DatabaseService _dbService;
  final Connectivity _connectivity;

  TodoRepository({
    required TodoApiService apiService,
    required DatabaseService dbService,
    Connectivity? connectivity,
  }) : _apiService = apiService,
       _dbService = dbService,
       _connectivity = connectivity ?? Connectivity();

  Future<bool> _hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result.first != ConnectivityResult.none;
  }

  Future<List<TodoItem>> getTodos() async {
    final hasInternet = await _hasInternet();
    AppLogger.log('Getting todos - Internet: $hasInternet', tag: 'REPO');

    if (hasInternet) {
      try {
        // First, sync any pending changes
        await syncPendingChanges();

        // Then fetch fresh data from API
        final remoteTodos = await _apiService.fetchTodos();

        // Clear only synced todos (pending ones already synced above)
        final pendingTodos = await _dbService.getPendingSyncTodos();
        await _dbService.clearAllTodos();

        // Save fresh data from API
        for (var todo in remoteTodos) {
          await _dbService.insertTodo(todo);
        }

        // Re-add any remaining pending changes (if sync failed for some)
        for (var todo in pendingTodos) {
          await _dbService.insertTodo(todo);
        }

        return await _dbService.getAllTodos();
      } catch (e) {
        // If API fails, fall back to local data
        return await _dbService.getAllTodos();
      }
    } else {
      return await _dbService.getAllTodos();
    }
  }

  Future<TodoItem> createTodo(TodoItem todo) async {
    final hasInternet = await _hasInternet();

    if (hasInternet) {
      try {
        final createdTodo = await _apiService.createTodo(todo);
        await _dbService.insertTodo(createdTodo);
        return createdTodo;
      } catch (e) {
        // Save to local with pending sync status
        final localTodo = todo.copyWith(
          id: DateTime.now().millisecondsSinceEpoch,
          syncStatus: 1, // pending create
        );
        await _dbService.insertTodo(localTodo);
        return localTodo;
      }
    } else {
      // Save to local with pending sync status
      final localTodo = todo.copyWith(
        id: DateTime.now().millisecondsSinceEpoch,
        syncStatus: 1, // pending create
      );
      await _dbService.insertTodo(localTodo);
      return localTodo;
    }
  }

  Future<TodoItem> updateTodo(TodoItem todo) async {
    final hasInternet = await _hasInternet();

    if (hasInternet) {
      try {
        final updatedTodo = await _apiService.updateTodo(todo);
        await _dbService.updateTodo(updatedTodo);
        return updatedTodo;
      } catch (e) {
        // Update locally with pending sync status
        final localTodo = todo.copyWith(
          syncStatus: 2, // pending update
          updatedAt: DateTime.now(),
        );
        await _dbService.updateTodo(localTodo);
        return localTodo;
      }
    } else {
      // Update locally with pending sync status
      final localTodo = todo.copyWith(
        syncStatus: 2, // pending update
        updatedAt: DateTime.now(),
      );
      await _dbService.updateTodo(localTodo);
      return localTodo;
    }
  }

  Future<void> deleteTodo(int id) async {
    final hasInternet = await _hasInternet();

    if (hasInternet) {
      try {
        await _apiService.deleteTodo(id);
        await _dbService.deleteTodo(id);
      } catch (e) {
        // Mark for deletion with pending sync status
        final todo = await _dbService.getTodoById(id);
        if (todo != null) {
          await _dbService.updateTodo(
            todo.copyWith(syncStatus: 3), // pending delete
          );
        }
      }
    } else {
      // Mark for deletion with pending sync status
      final todo = await _dbService.getTodoById(id);
      if (todo != null) {
        await _dbService.updateTodo(
          todo.copyWith(syncStatus: 3), // pending delete
        );
      }
    }
  }

  Future<void> syncPendingChanges() async {
    final hasInternet = await _hasInternet();
    if (!hasInternet) return;

    final pendingTodos = await _dbService.getPendingSyncTodos();
    AppLogger.log(
      'Syncing ${pendingTodos.length} pending changes',
      tag: 'SYNC',
    );

    for (var todo in pendingTodos) {
      try {
        switch (todo.syncStatus) {
          case 1: // pending create
            await _apiService.createTodo(todo);
            await _dbService.updateTodo(todo.copyWith(syncStatus: 0));
            break;
          case 2: // pending update
            await _apiService.updateTodo(todo);
            await _dbService.updateTodo(todo.copyWith(syncStatus: 0));
            break;
          case 3: // pending delete
            await _apiService.deleteTodo(todo.id);
            await _dbService.deleteTodo(todo.id);
            break;
        }
      } catch (e) {
        // Continue with next item if one fails
        continue;
      }
    }
  }
}
