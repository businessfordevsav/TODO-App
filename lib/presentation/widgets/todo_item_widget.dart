import 'package:flutter/material.dart';
import '../../data/models/todo_model.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoItem todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TodoItemWidget({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Checkbox(
          value: todo.isCompleted,
          onChanged: (_) => onToggle(),
        ),
        title: Text(
          todo.title,
          style: TextStyle(
            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
            color: todo.isCompleted ? Colors.grey : Colors.black,
          ),
        ),
        subtitle: _buildSubtitle(),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: onEdit,
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              onPressed: onDelete,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    final List<Widget> chips = [];

    if (todo.syncStatus != 0) {
      chips.add(
        Chip(
          label: Text(
            _getSyncStatusText(),
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: Colors.orange[100],
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Wrap(spacing: 4, children: chips),
    );
  }

  String _getSyncStatusText() {
    return switch (todo.syncStatus) {
      1 => 'Pending upload',
      2 => 'Pending update',
      3 => 'Pending delete',
      _ => 'Synced',
    };
  }
}
