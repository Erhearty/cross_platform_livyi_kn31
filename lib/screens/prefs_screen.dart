import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';
import '../main.dart';
import '../services/calendar_service.dart';
import '../services/weather_service.dart';
import '../theme_ext.dart';

// Демонстраційний екран SharedPreferences:
// збереження int, String, bool; оновлення; видалення; налаштування теми.
class PrefsScreen extends StatefulWidget {
  const PrefsScreen({super.key});

  @override
  State<PrefsScreen> createState() => _PrefsScreenState();
}

class _PrefsScreenState extends State<PrefsScreen> {
  // ---------- ключі ----------
  static const _kText          = 'demo_text';
  static const _kCounter       = 'demo_counter';
  static const _kNotifications = 'demo_notifications';
  static const _kDarkMode      = 'isDarkMode';

  // ---------- стан ----------
  final _textController = TextEditingController();

  String? _savedText;          // null = ключ відсутній у сховищі
  int     _counter       = 0;
  bool    _notifications = false;
  bool    _isDark        = false;

  // Weather
  String? _selectedCityName;

  // Google Calendar
  bool    _calendarSignedIn   = false;
  bool    _calendarSyncEnabled = false;
  String? _calendarUserEmail;

  // ---------- ініціалізація ----------
  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  // Зчитуємо всі значення при відкритті екрану
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final signedIn   = await CalendarService.isSignedIn();
    final syncEnabled = await CalendarService.isSyncEnabled();
    final cityData   = await WeatherService.getSelectedCity();
    setState(() {
      _savedText      = prefs.getString(_kText);
      _counter        = prefs.getInt(_kCounter)       ?? 0;
      _notifications  = prefs.getBool(_kNotifications) ?? false;
      _isDark         = prefs.getBool(_kDarkMode)       ?? false;
      _selectedCityName   = cityData?['name'];
      _calendarSignedIn   = signedIn;
      _calendarSyncEnabled = syncEnabled;
    });
    if (_savedText != null) _textController.text = _savedText!;
  }

  // ---------- String: setString / getString / remove ----------
  Future<void> _saveText() async {
    final text = _textController.text.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kText, text);          // setString
    setState(() => _savedText = text);
    _snack('Текст збережено (setString)');
  }

  Future<void> _readText() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getString(_kText);           // getString
    setState(() => _savedText = val);
    _snack(val != null ? 'Текст зчитано' : 'Ключ відсутній');
  }

  Future<void> _deleteText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kText);                    // remove
    setState(() => _savedText = null);
    _textController.clear();
    _snack('Текст видалено (remove)');
  }

  // ---------- int: setInt / getInt / remove ----------
  Future<void> _incrementAndSave() async {
    final next = _counter + 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kCounter, next);           // setInt
    setState(() => _counter = next);
  }

  Future<void> _readCounter() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getInt(_kCounter) ?? 0;      // getInt
    setState(() => _counter = val);
    _snack('Лічильник зчитано: $_counter');
  }

  Future<void> _resetCounter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kCounter);                 // remove
    setState(() => _counter = 0);
    _snack('Лічильник видалено (remove)');
  }

  // ---------- bool: setBool / getBool ----------
  // Switch автоматично зберігає значення при зміні (демонстрація setBool)
  Future<void> _saveNotifications(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, val);     // setBool
    setState(() => _notifications = val);
  }

  Future<void> _readNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_kNotifications) ?? false; // getBool
    setState(() => _notifications = val);
    _snack('Сповіщення: ${val ? "увімкнено" : "вимкнено"}');
  }

  // ---------- Практичне застосування: тема ----------
  // Вибір теми зберігається у SharedPreferences та застосовується до всього додатку
  Future<void> _setTheme(bool dark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, dark);         // setBool
    setState(() => _isDark = dark);
    if (!mounted) return;
    // Перемикаємо тему через статичний метод MyApp (без розкриття приватного стану)
    MyApp.setTheme(context, dark ? ThemeMode.dark : ThemeMode.light);
  }

  // ---------- Weather ----------
  Future<void> _setCityWeather(Map<String, String> city) async {
    await WeatherService.saveCity(city['name']!, city['lat']!, city['lon']!);
    setState(() => _selectedCityName = city['name']);
    _snack('Місто обрано: ${city['name']!}');
  }

  // ---------- Google Calendar ----------
  Future<void> _signInCalendar() async {
    final account = await CalendarService.signIn();
    if (account == null) {
      _snack('Вхід скасовано');
      return;
    }
    setState(() {
      _calendarSignedIn  = true;
      _calendarUserEmail = account.email;
    });
    _snack('Вхід виконано: ${account.email}');
  }

  Future<void> _signOutCalendar() async {
    await CalendarService.signOut();
    setState(() {
      _calendarSignedIn    = false;
      _calendarSyncEnabled = false;
      _calendarUserEmail   = null;
    });
    _snack('Вихід виконано. Події у Google Календарі збережені.');
  }

  Future<void> _setSyncEnabled(bool val) async {
    await CalendarService.setSyncEnabled(val);
    setState(() => _calendarSyncEnabled = val);
  }

  // ---------- допоміжні ----------
  void _snack(String msg) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SharedPreferences',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _header('String — рядок'),
          _buildStringCard(),
          const SizedBox(height: 20),

          _header('int — ціле число'),
          _buildIntCard(),
          const SizedBox(height: 20),

          _header('bool — булеве (сповіщення)'),
          _buildBoolCard(),
          const SizedBox(height: 20),

          _header('Практичне застосування: тема'),
          _buildThemeCard(),
          const SizedBox(height: 20),

          _header('Погода'),
          _buildWeatherCard(),
          const SizedBox(height: 20),

          _header('Google Календар'),
          _buildCalendarCard(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── 1. String ──────────────────────────────────────────────────────────────
  Widget _buildStringCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TextField для введення тексту (Завдання для самостійної роботи)
          TextField(
            controller: _textController,
            decoration: _fieldDecor('Введіть текст для збереження...'),
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 12),
          // Кнопки: Зберегти, Зчитати, Видалити
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('Зберегти', Icons.save,     AppColors.primary,   _saveText),
              _btn('Зчитати',  Icons.refresh,  AppColors.study,     _readText),
              _btn('Видалити', Icons.delete,   AppColors.deleteRed, _deleteText),
            ],
          ),
          if (_savedText != null) ...[
            const SizedBox(height: 10),
            const Divider(color: AppColors.divider),
            _valueRow('Збережено', '"$_savedText"'),
          ] else ...[
            const SizedBox(height: 10),
            _valueRow('Збережено', 'немає даних', dim: true),
          ],
        ],
      ),
    );
  }

  // ── 2. int ─────────────────────────────────────────────────────────────────
  Widget _buildIntCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _valueRow('Значення у пам\'яті', _counter.toString()),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _btn('+1 і зберегти', Icons.add,    AppColors.primary,   _incrementAndSave),
              _btn('Зчитати',       Icons.refresh, AppColors.study,     _readCounter),
              _btn('Видалити',      Icons.delete,  AppColors.deleteRed, _resetCounter),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. bool ────────────────────────────────────────────────────────────────
  Widget _buildBoolCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _valueRow(
                  'Сповіщення',
                  _notifications ? 'Увімкнено' : 'Вимкнено',
                  accent: _notifications ? AppColors.completed : AppColors.textSecondary,
                ),
              ),
              // Switch: автозбереження через setBool при кожній зміні
              Switch(
                value: _notifications,
                onChanged: _saveNotifications,
                activeColor: AppColors.completed,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _btn('Зчитати', Icons.refresh, AppColors.study, _readNotifications),
        ],
      ),
    );
  }

  // ── 4. Тема ────────────────────────────────────────────────────────────────
  Widget _buildThemeCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _valueRow('Поточна тема', _isDark ? 'Темна 🌙' : 'Світла ☀️'),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _themeBtn('Світла', Icons.light_mode, !_isDark, () => _setTheme(false))),
              const SizedBox(width: 12),
              Expanded(child: _themeBtn('Темна',  Icons.dark_mode,  _isDark,  () => _setTheme(true))),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Вибір зберігається у SharedPreferences та відновлюється при повторному запуску.',
            style: TextStyle(fontSize: 12, color: AppColors.textHint),
          ),
        ],
      ),
    );
  }

  // ── 5. Погода ──────────────────────────────────────────────────────────────
  Widget _buildWeatherCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _valueRow(
            'Поточне місто',
            _selectedCityName ?? 'не обрано',
            dim: _selectedCityName == null,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: kUkrainianCities.map((city) {
              final selected = _selectedCityName == city['name'];
              return _themeBtn(
                city['name']!,
                Icons.location_city,
                selected,
                () => _setCityWeather(city),
              );
            }).toList(),
          ),
          const SizedBox(height: 8),
          Text(
            'Дані надає open-meteo.com. Оновлення кожні 30 хвилин.',
            style: TextStyle(fontSize: 12, color: context.textHint),
          ),
        ],
      ),
    );
  }

  // ── 6. Google Календар ─────────────────────────────────────────────────────
  Widget _buildCalendarCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!_calendarSignedIn) ...[
            Text(
              'Синхронізуйте завдання з Google Календарем.',
              style: TextStyle(fontSize: 13, color: context.textSecondary),
            ),
            const SizedBox(height: 12),
            _btn('Увійти через Google', Icons.login, AppColors.primary, _signInCalendar),
          ] else ...[
            _valueRow('Акаунт', _calendarUserEmail ?? '—'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _valueRow(
                    'Синхронізація',
                    _calendarSyncEnabled ? 'Увімкнена' : 'Вимкнена',
                    accent: _calendarSyncEnabled ? AppColors.completed : null,
                  ),
                ),
                Switch(
                  value: _calendarSyncEnabled,
                  onChanged: _setSyncEnabled,
                  activeColor: AppColors.completed,
                ),
              ],
            ),
            const SizedBox(height: 8),
            _btn('Вийти', Icons.logout, AppColors.deleteRed, _signOutCalendar),
          ],
          const SizedBox(height: 8),
          Text(
            'При вході існуючі завдання автоматично додаються до Google Календаря.',
            style: TextStyle(fontSize: 12, color: context.textHint),
          ),
        ],
      ),
    );
  }

  // ── Допоміжні віджети ──────────────────────────────────────────────────────
  Widget _header(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 0.4,
      ),
    ),
  );

  Widget _card({required Widget child}) => Card(
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    child: Padding(padding: const EdgeInsets.all(16), child: child),
  );

  Widget _btn(String label, IconData icon, Color color, VoidCallback onTap) =>
      ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 15),
        label: Text(label, style: const TextStyle(fontSize: 12)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 1,
        ),
      );

  Widget _themeBtn(String label, IconData icon, bool selected, VoidCallback onTap) =>
      OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label, style: const TextStyle(fontSize: 14)),
        style: OutlinedButton.styleFrom(
          foregroundColor: selected ? Colors.white : AppColors.textSecondary,
          backgroundColor: selected ? AppColors.primary : Colors.transparent,
          side: BorderSide(color: selected ? AppColors.primary : AppColors.divider, width: selected ? 2 : 1),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

  Widget _valueRow(String label, String value, {Color? accent, bool dim = false}) => RichText(
    text: TextSpan(
      style: TextStyle(fontSize: 14, color: dim ? context.textHint : context.textSecondary),
      children: [
        TextSpan(text: '$label: '),
        TextSpan(
          text: value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: accent ?? (dim ? context.textHint : context.textPrimary),
          ),
        ),
      ],
    ),
  );

  InputDecoration _fieldDecor(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: context.textHint),
    filled: true,
    fillColor: context.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: context.divider),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
  );
}
