class TodoItem {
  final int id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int
  syncStatus; // 0 = synced, 1 = pending create, 2 = pending update, 3 = pending delete
  final int userId;

  TodoItem({
    required this.id,
    required this.title,
    required this.isCompleted,
    required this.createdAt,
    this.updatedAt,
    this.syncStatus = 0,
    this.userId = 1,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'completed': isCompleted,
      'userId': userId,
    };
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      isCompleted: json['completed'] ?? false,
      userId: json['userId'] ?? 1,
      createdAt: DateTime.now(),
      syncStatus: 0,
    );
  }

  Map<String, dynamic> toLocalStorage() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'syncStatus': syncStatus,
      'userId': userId,
    };
  }

  factory TodoItem.fromLocalStorage(Map<String, dynamic> map) {
    return TodoItem(
      id: map['id'],
      title: map['title'],
      isCompleted: map['isCompleted'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'])
          : null,
      syncStatus: map['syncStatus'],
      userId: map['userId'],
    );
  }

  TodoItem copyWith({
    int? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? syncStatus,
    int? userId,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      userId: userId ?? this.userId,
    );
  }
}
