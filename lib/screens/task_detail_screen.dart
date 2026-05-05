import 'package:flutter/material.dart';
import '../models/task.dart';
import '../colors.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _isCompleted = widget.task.isCompleted;
  }

  // Іконка та колір категорії
  IconData _categoryIcon(String category) {
    switch (category) {
      case 'work':     return Icons.work;
      case 'personal': return Icons.person;
      case 'study':    return Icons.school;
      case 'shopping': return Icons.shopping_cart;
      default:         return Icons.label;
    }
  }

  Color _categoryColor(String category) {
    switch (category) {
      case 'work':     return AppColors.work;
      case 'personal': return AppColors.personal;
      case 'study':    return AppColors.study;
      case 'shopping': return AppColors.shopping;
      default:         return AppColors.primary;
    }
  }

  // Форматування дати з часом
  String _formatDateTime(DateTime dt) {
    final date =
        '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date о $time';
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final catColor = _categoryColor(task.category);
    final catIcon = _categoryIcon(task.category);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Деталі завдання',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              print('[TaskDetail] Редагування завдання: ${task.id}');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Редагування буде додано пізніше'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            const SizedBox(height: 16),

            // --- Велика іконка категорії ---
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: catColor.withOpacity(0.15),
              ),
              child: Icon(catIcon, size: 52, color: catColor),
            ),

            const SizedBox(height: 16),

            // --- Назва завдання ---
            Text(
              task.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: 12),

            // --- Теги: категорія та пріоритет ---
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTag(
                  icon: catIcon,
                  label: Task.categoryLabel(task.category),
                  color: catColor,
                ),
                const SizedBox(width: 8),
                _buildTag(
                  icon: Icons.priority_high,
                  label: 'Високий пріоритет',
                  color: AppColors.high,
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- Блок опису ---
            if (task.description.isNotEmpty)
              Card(
                elevation: 2,
                shadowColor: AppColors.cardShadow,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.description_outlined,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Опис',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        task.description,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // --- Блок дат ---
            Card(
              elevation: 2,
              shadowColor: AppColors.cardShadow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Column(
                children: [
                  _buildDateRow(
                    icon: Icons.edit_calendar_outlined,
                    iconColor: Colors.green,
                    label: 'Створено',
                    value: _formatDateTime(task.date),
                    showDivider: task.deadline != null,
                  ),
                  if (task.deadline != null)
                    _buildDateRow(
                      icon: Icons.event_outlined,
                      iconColor: AppColors.deleteRed,
                      label: 'Дедлайн',
                      value: _formatDateTime(task.deadline!),
                      showDivider: false,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // --- Статус виконання з Switch ---
            Card(
              elevation: 2,
              shadowColor: AppColors.cardShadow,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isCompleted
                            ? AppColors.completed.withOpacity(0.15)
                            : AppColors.pending.withOpacity(0.2),
                      ),
                      child: Icon(
                        _isCompleted
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        color: _isCompleted
                            ? AppColors.completed
                            : AppColors.pending,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Статус виконання',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Switch(
                      value: _isCompleted,
                      onChanged: (val) {
                        setState(() {
                          _isCompleted = val;
                          task.isCompleted = val;
                        });
                        print(
                            '[TaskDetail] Статус: ${val ? "Виконано" : "Не виконано"}');
                      },
                      activeColor: AppColors.completed,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // --- Кнопки дій ---
            Row(
              children: [
                // Редагувати
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      print('[TaskDetail] Редагування: ${task.id}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Редагування буде додано пізніше')),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Редагувати'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Видалити
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      print('[TaskDetail] Видалення: ${task.id}');
                      _showDeleteDialog(context);
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Видалити'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.deleteRed,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Тег з іконкою та підписом
  Widget _buildTag({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Рядок дати з іконкою
  Widget _buildDateRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required bool showDivider,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withOpacity(0.12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }

  // Діалог підтвердження видалення
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Видалити завдання?'),
        content:
            const Text('Ця дія незворотна. Завдання буде видалено назавжди.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Закрити діалог
              Navigator.pop(context); // Повернутись до списку
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.deleteRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }
}