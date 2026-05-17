import 'package:flutter/material.dart';
import '../models/task.dart';
import '../colors.dart';
import '../routes.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tasks = [
      Task(
        id: '1',
        title: 'Підготувати звіт для клієнта',
        description: 'Підготувати квартальний звіт. Включити всі ключові показники.',
        isCompleted: true,
        category: 'work',
        priority: 'high',
        createdAt: DateTime(2026, 3, 10, 14, 30),
        deadline: DateTime(2026, 3, 15, 18, 0),
      ),
      Task(
        id: '2',
        title: 'Зустріч з командою',
        description: 'Обговорити плани на наступний спринт.',
        isCompleted: false,
        category: 'work',
        priority: 'medium',
        createdAt: DateTime(2026, 3, 10),
        deadline: DateTime(2026, 3, 20),
      ),
      Task(
        id: '3',
        title: 'Прочитати книгу',
        description: 'Дочитати "Clean Code".',
        isCompleted: true,
        category: 'study',
        priority: 'low',
        createdAt: DateTime(2026, 3, 8),
      ),
      Task(
        id: '4',
        title: 'Купити продукти',
        description: 'Молоко, хліб, овочі, фрукти.',
        isCompleted: false,
        category: 'shopping',
        priority: 'medium',
        createdAt: DateTime(2026, 3, 9),
        deadline: DateTime(2026, 3, 11),
      ),
      Task(
        id: '5',
        title: 'Похід у спортзал',
        description: 'Тренування — кардіо + силові вправи.',
        isCompleted: false,
        category: 'personal',
        priority: 'low',
        createdAt: DateTime(2026, 3, 10),
      ),
      Task(
        id: '6',
        title: 'Вивчити Flutter',
        description: 'Пройти урок про StatefulWidget.',
        isCompleted: true,
        category: 'study',
        priority: 'high',
        createdAt: DateTime(2026, 3, 7),
        deadline: DateTime(2026, 3, 26),
      ),
    ];
  }

  void _toggleTaskStatus(String id) {
    setState(() {
      final task = _tasks.firstWhere((t) => t.id == id);
      task.isCompleted = !task.isCompleted;
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((t) => t.id == id);
    });
  }

  void _updateTask(Task updated) {
    setState(() {
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) _tasks[index] = updated;
    });
  }

  // Перехід на AddTaskScreen; очікуємо Task? — якщо не null, додаємо до списку
  void _navigateToAddTask() async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.addTask,
      arguments: const AddTaskArguments(),
    );
    if (!mounted) return;
    if (result != null) {
      setState(() => _tasks.add(result as Task));
    }
  }

  // Перехід на TaskDetailScreen; очікуємо Task? —
  // Task → оновити, null → видалити
  void _onTaskTapped(Task task) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.taskDetail,
      arguments: TaskDetailArguments(task: task),
    );
    if (!mounted) return;
    if (result == null) {
      _deleteTask(task.id);
    } else {
      _updateTask(result as Task);
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Мої завдання',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _tasks.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              itemCount: _tasks.length,
              itemBuilder: (context, index) => TaskListItem(
                task: _tasks[index],
                onTap: () => _onTaskTapped(_tasks[index]),
                onToggle: () => _toggleTaskStatus(_tasks[index].id),
                onDelete: () => _deleteTask(_tasks[index].id),
                formatDate: _formatDate,
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          const Text(
            'Завдань немає',
            style: TextStyle(fontSize: 20, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          const Text(
            'Натисніть + щоб додати нове завдання',
            style: TextStyle(color: AppColors.textHint),
          ),
        ],
      ),
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String Function(DateTime) formatDate;

  const TaskListItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    required this.formatDate,
  }) : super(key: key);

  IconData _categoryIcon(String c) {
    switch (c) {
      case 'work':     return Icons.work;
      case 'personal': return Icons.person;
      case 'study':    return Icons.school;
      case 'shopping': return Icons.shopping_cart;
      default:         return Icons.label;
    }
  }

  Color _categoryColor(String c) {
    switch (c) {
      case 'work':     return AppColors.work;
      case 'personal': return AppColors.personal;
      case 'study':    return AppColors.study;
      case 'shopping': return AppColors.shopping;
      default:         return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      elevation: 2,
      shadowColor: AppColors.cardShadow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (_) => onToggle(),
                activeColor: AppColors.completed,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? AppColors.textHint : AppColors.textPrimary,
                        decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Створено: ${formatDate(task.createdAt)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Icon(_categoryIcon(task.category), color: _categoryColor(task.category), size: 22),
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.deleteRed),
                onPressed: onDelete,
                splashRadius: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
