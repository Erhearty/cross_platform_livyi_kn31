import 'package:flutter/material.dart';
import '../models/task.dart';
import '../colors.dart';

class AddTaskScreen extends StatefulWidget {
  // null = режим додавання, не-null = режим редагування
  final Task? existingTask;

  const AddTaskScreen({Key? key, this.existingTask}) : super(key: key);

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedCategory = 'work';
  String _selectedPriority = 'high';
  late DateTime _selectedDate;

  bool get _isEditing => widget.existingTask != null;

  static const List<Map<String, dynamic>> _categories = [
    {'id': 'work',     'label': 'Робота',   'icon': Icons.work,          'color': AppColors.work},
    {'id': 'personal', 'label': 'Особисте', 'icon': Icons.person,        'color': AppColors.personal},
    {'id': 'study',    'label': 'Навчання', 'icon': Icons.school,        'color': AppColors.study},
    {'id': 'shopping', 'label': 'Покупки',  'icon': Icons.shopping_cart, 'color': AppColors.shopping},
  ];

  static const List<Map<String, dynamic>> _priorities = [
    {'id': 'high',   'label': 'Високий',  'color': AppColors.high},
    {'id': 'medium', 'label': 'Середній', 'color': AppColors.medium},
    {'id': 'low',    'label': 'Низький',  'color': AppColors.low},
  ];

  @override
  void initState() {
    super.initState();
    final existing = widget.existingTask;
    if (existing != null) {
      // Режим редагування — заповнюємо поля з існуючого завдання
      _titleController.text = existing.title;
      _descriptionController.text = existing.description;
      _selectedCategory = existing.category;
      _selectedPriority = existing.priority;
      _selectedDate = existing.deadline ?? DateTime.now().add(const Duration(days: 7));
    } else {
      _selectedDate = DateTime.now().add(const Duration(days: 7));
    }
  }

  String get _formattedDate =>
      '${_selectedDate.day.toString().padLeft(2, '0')}.${_selectedDate.month.toString().padLeft(2, '0')}.${_selectedDate.year}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2027),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  // Створює/оновлює Task і повертає його через Navigator.pop
  void _saveTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Введіть назву завдання'),
          backgroundColor: AppColors.deleteRed,
        ),
      );
      return;
    }

    final existing = widget.existingTask;
    final task = Task(
      id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descriptionController.text.trim(),
      isCompleted: existing?.isCompleted ?? false,
      category: _selectedCategory,
      priority: _selectedPriority,
      createdAt: existing?.createdAt ?? DateTime.now(),
      deadline: _selectedDate,
    );

    // Повертаємо Task на попередній екран
    Navigator.pop(context, task);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Редагувати завдання' : 'Нове завдання',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          // Закриває без повернення даних
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionLabel('Назва завдання'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: _inputDecoration('Введіть назву завдання'),
              maxLength: 80,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 8),

            _buildSectionLabel('Опис'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecoration('Додайте детальний опис завдання'),
              maxLines: 4,
              style: const TextStyle(fontSize: 15),
            ),

            const SizedBox(height: 20),

            _buildSectionLabel('Категорія'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat['id'] as String),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? (cat['color'] as Color).withOpacity(0.15)
                              : Colors.grey.shade100,
                          border: isSelected
                              ? Border.all(color: cat['color'] as Color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? cat['color'] as Color : AppColors.textHint,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? cat['color'] as Color : AppColors.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _buildSectionLabel('Дата виконання'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    Text(
                      _formattedDate,
                      style: const TextStyle(fontSize: 15, color: AppColors.textPrimary),
                    ),
                    const Spacer(),
                    const Icon(Icons.calendar_today_outlined,
                        color: AppColors.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildSectionLabel('Пріоритет'),
            const SizedBox(height: 12),
            Row(
              children: _priorities.map((p) {
                final isSelected = _selectedPriority == p['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedPriority = p['id'] as String),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: p['color'] as Color,
                      side: BorderSide(
                        color: isSelected ? p['color'] as Color : AppColors.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      backgroundColor: isSelected
                          ? (p['color'] as Color).withOpacity(0.08)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text(
                      p['label'] as String,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 32),

            // Кнопки «Скасувати» та «Створити / Зберегти»
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    // Закриває екран без повернення даних
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Скасувати', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveTask,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 3,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isEditing ? 'Зберегти' : 'Створити',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textHint),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      counterStyle: const TextStyle(color: AppColors.textHint),
    );
  }
}
