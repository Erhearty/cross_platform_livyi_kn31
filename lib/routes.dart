import 'package:flutter/material.dart';
import 'models/task.dart';
import 'screens/task_list_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/task_detail_screen.dart';
import 'screens/prefs_screen.dart';

class AppRoutes {
  static const String taskList  = '/';
  static const String addTask   = '/add-task';
  static const String taskDetail = '/task-detail';
  static const String prefsDemo = '/prefs-demo';
}

// existingTask == null → режим додавання; != null → режим редагування
class AddTaskArguments {
  final Task? existingTask;
  const AddTaskArguments({this.existingTask});
}

class TaskDetailArguments {
  final Task task;
  const TaskDetailArguments({required this.task});
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.taskList:
      return MaterialPageRoute(builder: (_) => const TaskListScreen());

    case AppRoutes.addTask:
      final args = settings.arguments as AddTaskArguments?;
      return MaterialPageRoute(
        builder: (_) => AddTaskScreen(existingTask: args?.existingTask),
      );

    case AppRoutes.taskDetail:
      final args = settings.arguments as TaskDetailArguments;
      return MaterialPageRoute(
        builder: (_) => TaskDetailScreen(task: args.task),
      );

    case AppRoutes.prefsDemo:
      return MaterialPageRoute(builder: (_) => const PrefsScreen());

    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Маршрут "${settings.name}" не знайдено'),
          ),
        ),
      );
  }
}
