import 'package:shared_preferences/shared_preferences.dart';

class CacheHelper {
  static late SharedPreferences sharedPreferences;

  /// Initialize the SharedPreferences instance
  static Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  /// Generic method to save any data type to local storage
  static Future<bool> saveData({required String key, required dynamic value}) async {
    if (value == null) {
      return await sharedPreferences.remove(key);
    }
    if (value is String) {
      return await sharedPreferences.setString(key, value);
    }
    if (value is bool) {
      return await sharedPreferences.setBool(key, value);
    }
    if (value is int) {
      return await sharedPreferences.setInt(key, value);
    }
    if (value is double) {
      return await sharedPreferences.setDouble(key, value);
    }
    if (value is List<String>) {
      return await sharedPreferences.setStringList(key, value);
    }
    return false;
  }

  /// Generic method to get data from local storage
  static dynamic getData({required String key}) {
    return sharedPreferences.get(key);
  }

  /// Strongly-typed getters for common types
  static bool? getBool({required String key}) {
    return sharedPreferences.getBool(key);
  }

  static String? getString({required String key}) {
    return sharedPreferences.getString(key);
  }

  static int? getInt({required String key}) {
    return sharedPreferences.getInt(key);
  }

  static double? getDouble({required String key}) {
    return sharedPreferences.getDouble(key);
  }

  static List<String>? getStringList({required String key}) {
    return sharedPreferences.getStringList(key);
  }

  /// Remove data for a specific key
  static Future<bool> removeData({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  /// Check if local storage contains a specific key
  static bool containsKey({required String key}) {
    return sharedPreferences.containsKey(key);
  }

  /// Clear all data in the local storage
  static Future<bool> clearData() async {
    return await sharedPreferences.clear();
  }
}