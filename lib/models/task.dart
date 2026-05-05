// Модель даних для завдання
class Task {
  final String id;
  String title;
  String description;
  bool isCompleted;
  String category; // 'work', 'personal', 'study', 'shopping'
  DateTime date;
  DateTime? deadline;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.category = 'work',
    required this.date,
    this.deadline,
  });

  // Іконка категорії
  static String categoryLabel(String category) {
    switch (category) {
      case 'work':
        return 'Робота';
      case 'personal':
        return 'Особисте';
      case 'study':
        return 'Навчання';
      case 'shopping':
        return 'Покупки';
      default:
        return 'Інше';
    }
  }
}