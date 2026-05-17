import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'colors.dart';
import 'routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  static void setTheme(BuildContext context, ThemeMode mode) {
    context.findAncestorStateOfType<_MyAppState>()?.setThemeMode(mode);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkMode') ?? false;
    if (mounted) {
      setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);
    }
  }

  void setThemeMode(ThemeMode mode) => setState(() => _themeMode = mode);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // ── Світла тема ──────────────────────────────────────────────────────
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.surface,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.completed : null),
        ),
      ),

      // ── Темна тема (Deep Indigo) ─────────────────────────────────────────
      //
      // Палітра:
      //   #0C0C1C — scaffold (майже чорний з фіолетовим відтінком)
      //   #15152A — картки (трохи світліше)
      //   #1C1C32 — surface / поля вводу
      //   #26264A — divider / межі
      //   #7986CB — primary (легший індиго для темного фону)
      //   #E2E2F5 — основний текст
      //   #9898B8 — вторинний текст
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0C0C1C),

        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ).copyWith(
          primary: const Color(0xFF7986CB),
          onPrimary: Colors.white,
          secondary: AppColors.accent,
          surface: const Color(0xFF15152A),
          onSurface: const Color(0xFFE2E2F5),
          surfaceContainerLowest: const Color(0xFF0C0C1C),
          surfaceContainerLow:    const Color(0xFF13132A),
          surfaceContainer:       const Color(0xFF15152A),
          surfaceContainerHigh:   const Color(0xFF1C1C32),
          surfaceContainerHighest: const Color(0xFF26264A),
          outline: const Color(0xFF26264A),
        ),

        // Картки
        cardTheme: CardThemeData(
          elevation: 4,
          color: const Color(0xFF15152A),
          shadowColor: Colors.black54,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),

        // AppBar — зберігаємо primary indigo для впізнаваності
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1A1A38),
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // Роздільник
        dividerColor: const Color(0xFF26264A),

        // Поля вводу
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFF1C1C32),
          filled: true,
          hintStyle: const TextStyle(color: Color(0xFF505070)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF26264A)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF26264A)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF7986CB), width: 2),
          ),
          counterStyle: const TextStyle(color: Color(0xFF505070)),
        ),

        // FAB
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF5C6BC0),
          foregroundColor: Colors.white,
        ),

        // Checkbox
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.completed : null),
          side: const BorderSide(color: Color(0xFF505070)),
        ),

        // Switch
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected) ? AppColors.completed : const Color(0xFF505070)),
          trackColor: WidgetStateProperty.resolveWith((s) =>
              s.contains(WidgetState.selected)
                  ? AppColors.completed.withValues(alpha: 0.35)
                  : const Color(0xFF26264A)),
        ),

        // Кнопки
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C6BC0),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // Текстова тема
        textTheme: const TextTheme(
          bodyLarge:   TextStyle(color: Color(0xFFE2E2F5)),
          bodyMedium:  TextStyle(color: Color(0xFFE2E2F5)),
          bodySmall:   TextStyle(color: Color(0xFF9898B8)),
          labelLarge:  TextStyle(color: Color(0xFFE2E2F5)),
          labelMedium: TextStyle(color: Color(0xFF9898B8)),
          labelSmall:  TextStyle(color: Color(0xFF9898B8)),
          titleLarge:  TextStyle(color: Color(0xFFE2E2F5)),
          titleMedium: TextStyle(color: Color(0xFFE2E2F5)),
          titleSmall:  TextStyle(color: Color(0xFFE2E2F5)),
        ),
      ),

      initialRoute: AppRoutes.taskList,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
