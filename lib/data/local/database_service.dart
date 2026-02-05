import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/todo_model.dart';
import '../../core/utils/logger.dart';

class DatabaseService {
  static Database? _db;
  static const String _tableName = 'todos';

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'todos.db');

    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableName (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        isCompleted INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT,
        syncStatus INTEGER NOT NULL,
        userId INTEGER NOT NULL
      )
    ''');
  }

  Future<int> insertTodo(TodoItem todo) async {
    AppLogger.db('INSERT', table: 'todos', data: 'id: ${todo.id}');
    final db = await database;
    return await db.insert(
      _tableName,
      todo.toLocalStorage(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<TodoItem>> getAllTodos() async {
    AppLogger.db('SELECT ALL', table: 'todos');
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => TodoItem.fromLocalStorage(map)).toList();
  }

  Future<TodoItem?> getTodoById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return TodoItem.fromLocalStorage(maps.first);
  }

  Future<int> updateTodo(TodoItem todo) async {
    AppLogger.db('UPDATE', table: 'todos', data: 'id: ${todo.id}');
    final db = await database;
    return await db.update(
      _tableName,
      todo.toLocalStorage(),
      where: 'id = ?',
      whereArgs: [todo.id],
    );
  }

  Future<int> deleteTodo(int id) async {
    AppLogger.db('DELETE', table: 'todos', data: 'id: $id');
    final db = await database;
    return await db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TodoItem>> getPendingSyncTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _tableName,
      where: 'syncStatus != ?',
      whereArgs: [0],
    );
    return maps.map((map) => TodoItem.fromLocalStorage(map)).toList();
  }

  Future<void> clearAllTodos() async {
    final db = await database;
    await db.delete(_tableName);
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
