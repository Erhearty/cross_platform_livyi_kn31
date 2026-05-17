import 'package:flutter/material.dart';
import '../models/task.dart';
import '../colors.dart';
import '../theme_ext.dart';

class AddTaskScreen extends StatefulWidget {
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
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

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
      backgroundColor: context.bg,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Редагувати завдання' : 'Нове завдання',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Назва завдання'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: _inputDecor('Введіть назву завдання'),
              maxLength: 80,
              style: TextStyle(fontSize: 15, color: context.textPrimary),
            ),

            const SizedBox(height: 8),

            _sectionLabel('Опис'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: _inputDecor('Додайте детальний опис завдання'),
              maxLines: 4,
              style: TextStyle(fontSize: 15, color: context.textPrimary),
            ),

            const SizedBox(height: 20),

            _sectionLabel('Категорія'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat['id'];
                final color = cat['color'] as Color;
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
                              ? color.withValues(alpha: 0.15)
                              : context.inactiveBg,
                          border: isSelected
                              ? Border.all(color: color, width: 2)
                              : null,
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: isSelected ? color : context.textHint,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cat['label'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? color : context.textSecondary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            _sectionLabel('Дата виконання'),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.divider),
                ),
                child: Row(
                  children: [
                    Text(
                      _formattedDate,
                      style: TextStyle(fontSize: 15, color: context.textPrimary),
                    ),
                    const Spacer(),
                    Icon(Icons.calendar_today_outlined,
                        color: context.textSecondary, size: 20),
                    const SizedBox(width: 8),
                    Icon(Icons.arrow_drop_down, color: context.textSecondary),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            _sectionLabel('Пріоритет'),
            const SizedBox(height: 12),
            Row(
              children: _priorities.map((p) {
                final isSelected = _selectedPriority == p['id'];
                final color = p['color'] as Color;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: OutlinedButton(
                    onPressed: () => setState(() => _selectedPriority = p['id'] as String),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(
                        color: isSelected ? color : context.divider,
                        width: isSelected ? 2 : 1,
                      ),
                      backgroundColor: isSelected
                          ? color.withValues(alpha: 0.12)
                          : context.surface,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
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

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: context.textSecondary,
                      side: BorderSide(color: context.divider),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
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
                          borderRadius: BorderRadius.circular(14)),
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

  Widget _sectionLabel(String text) => Text(
    text,
    style: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: context.textSecondary,
      letterSpacing: 0.5,
    ),
  );

  InputDecoration _inputDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: context.textHint),
    filled: true,
    fillColor: context.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.divider),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: context.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    counterStyle: TextStyle(color: context.textHint),
  );
}
