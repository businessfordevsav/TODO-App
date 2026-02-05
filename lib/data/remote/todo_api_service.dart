import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../config/environment_config.dart';
import '../models/todo_model.dart';
import '../../core/exceptions/app_exceptions.dart';
import '../../core/utils/logger.dart';

class TodoApiService {
  final http.Client _client;
  final String _baseUrl;

  TodoApiService({http.Client? client})
    : _client = client ?? http.Client(),
      _baseUrl = EnvironmentConfig.apiBaseUrl;

  Future<List<TodoItem>> fetchTodos({int limit = 20}) async {
    AppLogger.api('GET', '$_baseUrl/todos?_limit=$limit');
    try {
      final response = await _client
          .get(
            Uri.parse('$_baseUrl/todos?_limit=$limit'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        AppLogger.api('GET', '$_baseUrl/todos', statusCode: 200);
        return data.map((json) => TodoItem.fromJson(json)).toList();
      } else {
        AppLogger.error(
          'Failed to fetch todos',
          error: 'Status: ${response.statusCode}',
        );
        throw ApiException('Failed to fetch todos: ${response.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Fetch todos failed', error: e);
      if (e is TimeoutException || e is ApiException) rethrow;
      throw NetworkException('Network error occurred: $e');
    }
  }

  Future<TodoItem> createTodo(TodoItem todo) async {
    AppLogger.api('POST', '$_baseUrl/todos', data: todo.toJson());
    try {
      final response = await _client
          .post(
            Uri.parse('$_baseUrl/todos'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(todo.toJson()),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        AppLogger.api('POST', '$_baseUrl/todos', statusCode: 201);
        return TodoItem.fromJson(data);
      } else {
        throw ApiException('Failed to create todo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException || e is ApiException) rethrow;
      throw NetworkException('Network error occurred: $e');
    }
  }

  Future<TodoItem> updateTodo(TodoItem todo) async {
    try {
      final response = await _client
          .put(
            Uri.parse('$_baseUrl/todos/${todo.id}'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(todo.toJson()),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return TodoItem.fromJson(data);
      } else {
        throw ApiException('Failed to update todo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException || e is ApiException) rethrow;
      throw NetworkException('Network error occurred: $e');
    }
  }

  Future<void> deleteTodo(int id) async {
    try {
      final response = await _client
          .delete(
            Uri.parse('$_baseUrl/todos/$id'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () => throw TimeoutException(),
          );

      if (response.statusCode != 200) {
        throw ApiException('Failed to delete todo: ${response.statusCode}');
      }
    } catch (e) {
      if (e is TimeoutException || e is ApiException) rethrow;
      throw NetworkException('Network error occurred: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
