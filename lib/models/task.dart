class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  String category; // 'work', 'personal', 'study', 'shopping'
  String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;
  DateTime? deadline;
  String? calendarEventId;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.category = 'work',
    this.priority = 'high',
    required this.createdAt,
    this.deadline,
    this.calendarEventId,
  });

  static String categoryLabel(String category) {
    switch (category) {
      case 'work':     return 'Робота';
      case 'personal': return 'Особисте';
      case 'study':    return 'Навчання';
      case 'shopping': return 'Покупки';
      default:         return 'Інше';
    }
  }

  static String priorityLabel(String priority) {
    switch (priority) {
      case 'high':   return 'Високий пріоритет';
      case 'medium': return 'Середній пріоритет';
      case 'low':    return 'Низький пріоритет';
      default:       return '';
    }
  }

  // Серіалізація для збереження у SharedPreferences
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'isCompleted': isCompleted,
    'category': category,
    'priority': priority,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'deadline': deadline?.millisecondsSinceEpoch,
    'calendarEventId': calendarEventId,
  };

  factory Task.fromJson(Map<String, dynamic> map) => Task(
    id: map['id'] as String,
    title: map['title'] as String,
    description: (map['description'] as String?) ?? '',
    isCompleted: map['isCompleted'] as bool,
    category: map['category'] as String,
    priority: map['priority'] as String,
    createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] as int),
    deadline: map['deadline'] != null
        ? DateTime.fromMillisecondsSinceEpoch(map['deadline'] as int)
        : null,
    calendarEventId: map['calendarEventId'] as String?,
  );
}
