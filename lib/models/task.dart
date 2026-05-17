class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  String category; // 'work', 'personal', 'study', 'shopping'
  String priority; // 'high', 'medium', 'low'
  final DateTime createdAt;
  DateTime? deadline;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.category = 'work',
    this.priority = 'high',
    required this.createdAt,
    this.deadline,
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
}
