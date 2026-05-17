import 'package:flutter/material.dart';
import '../colors.dart';
import '../services/weather_service.dart';
import '../theme_ext.dart';

class WeatherAppBarBottom extends StatefulWidget implements PreferredSizeWidget {
  const WeatherAppBarBottom({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(28);

  @override
  State<WeatherAppBarBottom> createState() => WeatherAppBarBottomState();
}

class WeatherAppBarBottomState extends State<WeatherAppBarBottom> {
  WeatherData? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final data = await WeatherService.getWeather();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
  }

  void refresh() => _fetch();

  @override
  Widget build(BuildContext context) {
    if (_loading || _data == null) return const SizedBox.shrink();

    final bg = context.isDark ? const Color(0xFF1A1A38) : AppColors.primaryDark;
    final city = _cityName();

    return Container(
      height: 28,
      color: bg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            WeatherService.iconForCode(_data!.weatherCode),
            color: Colors.white70,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            '${_data!.temperature.toStringAsFixed(1)}°C${city != null ? '  •  $city' : ''}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String? _cityName() {
    // Read synchronously from the widget's last-known state; not available here,
    // so city name is shown via the prefs on next refresh. Omit for simplicity.
    return null;
  }
}
