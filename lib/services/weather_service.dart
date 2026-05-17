import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final double temperature;
  final int weatherCode;
  const WeatherData({required this.temperature, required this.weatherCode});
}

const kUkrainianCities = [
  {'name': 'Київ',   'lat': '50.4501', 'lon': '30.5234'},
  {'name': 'Львів',  'lat': '49.8397', 'lon': '24.0297'},
  {'name': 'Харків', 'lat': '49.9935', 'lon': '36.2304'},
  {'name': 'Одеса',  'lat': '46.4825', 'lon': '30.7233'},
  {'name': 'Дніпро', 'lat': '48.4647', 'lon': '35.0462'},
];

class WeatherService {
  static const _kCity = 'weather_city';
  static const _kLat  = 'weather_lat';
  static const _kLon  = 'weather_lon';
  static const _kTemp = 'weather_cache_temp';
  static const _kCode = 'weather_cache_code';
  static const _kTs   = 'weather_cache_ts';

  static const _cacheTtlMs = 30 * 60 * 1000; // 30 minutes

  static Future<Map<String, String>?> getSelectedCity() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_kCity);
    final lat  = prefs.getString(_kLat);
    final lon  = prefs.getString(_kLon);
    if (name == null || lat == null || lon == null) return null;
    return {'name': name, 'lat': lat, 'lon': lon};
  }

  static Future<void> saveCity(String name, String lat, String lon) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kCity, name);
    await prefs.setString(_kLat, lat);
    await prefs.setString(_kLon, lon);
    await prefs.remove(_kTs); // invalidate cache
  }

  static Future<WeatherData?> getWeather() async {
    final city = await getSelectedCity();
    if (city == null) return null;

    final prefs = await SharedPreferences.getInstance();
    final cachedTs = prefs.getInt(_kTs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final cachedTemp = prefs.getString(_kTemp);
    final cachedCode = prefs.getInt(_kCode);

    if ((now - cachedTs) < _cacheTtlMs && cachedTemp != null && cachedCode != null) {
      return WeatherData(
        temperature: double.parse(cachedTemp),
        weatherCode: cachedCode,
      );
    }

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=${city['lat']}&longitude=${city['lon']}'
        '&current=temperature_2m,weather_code&timezone=auto',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final current = data['current'] as Map<String, dynamic>;
        final temp = (current['temperature_2m'] as num).toDouble();
        final code = current['weather_code'] as int;
        await prefs.setString(_kTemp, temp.toString());
        await prefs.setInt(_kCode, code);
        await prefs.setInt(_kTs, now);
        return WeatherData(temperature: temp, weatherCode: code);
      }
    } catch (_) {
      // fall through to stale cache
    }

    if (cachedTemp != null && cachedCode != null) {
      return WeatherData(
        temperature: double.parse(cachedTemp),
        weatherCode: cachedCode,
      );
    }
    return null;
  }

  static IconData iconForCode(int code) {
    if (code == 0) return Icons.wb_sunny;
    if (code <= 3) return Icons.wb_cloudy;
    if (code == 45 || code == 48) return Icons.blur_on;
    if (code >= 51 && code <= 67) return Icons.grain;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 80 && code <= 82) return Icons.beach_access;
    if (code == 85 || code == 86) return Icons.ac_unit;
    if (code == 95 || code == 96 || code == 99) return Icons.bolt;
    return Icons.cloud;
  }
}
