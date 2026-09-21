import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';

abstract final class StorageHelper {
  static late SharedPreferences _preferences;

  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static String get languageCode =>
      _preferences.getString(AppConstants.languageKey) ?? 'en';

  static Future<void> setLanguage(String value) =>
      _preferences.setString(AppConstants.languageKey, value);

  static Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  static String getString(String key, {String defaultValue = ''}) =>
      _preferences.getString(key) ?? defaultValue;

  static Future<void> setBool(String key, {required bool value}) =>
      _preferences.setBool(key, value);

  static bool getBool(String key, {bool defaultValue = false}) =>
      _preferences.getBool(key) ?? defaultValue;

  static Future<void> remove(String key) => _preferences.remove(key);
}
