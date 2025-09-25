import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static Future<void> savePrayerPrefs(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  static Future<bool> getPrayerPrefs(String key, {bool defaultValue = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? defaultValue;
  }
}