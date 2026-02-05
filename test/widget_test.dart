import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/data/models/todo_model.dart';

void main() {
  group('TodoItem Model Tests', () {
    test('TodoItem should be created from JSON', () {
      final json = {
        'id': 1,
        'title': 'Test Todo',
        'completed': false,
        'userId': 1,
      };

      final todo = TodoItem.fromJson(json);

      expect(todo.id, 1);
      expect(todo.title, 'Test Todo');
      expect(todo.isCompleted, false);
      expect(todo.userId, 1);
    });

    test('TodoItem should convert to JSON', () {
      final todo = TodoItem(
        id: 1,
        title: 'Test Todo',
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: 1,
      );

      final json = todo.toJson();

      expect(json['id'], 1);
      expect(json['title'], 'Test Todo');
      expect(json['completed'], false);
      expect(json['userId'], 1);
    });

    test('TodoItem copyWith should work correctly', () {
      final todo = TodoItem(
        id: 1,
        title: 'Original',
        isCompleted: false,
        createdAt: DateTime.now(),
        userId: 1,
      );

      final updated = todo.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.id, 1);
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.userId, 1);
    });
  });
}
