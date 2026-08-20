import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:helpdesk/core/database/cache/cache_helper.dart';
import 'package:helpdesk/core/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  static const String _themeCacheKey = 'app_theme_mode';

  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.system)) {
    _loadThemeFromCache();
  }

  /// Loads the persisted theme mode from SharedPreferences
  void _loadThemeFromCache() {
    final cached = CacheHelper.getString(key: _themeCacheKey);
    if (cached == 'dark') {
      emit(state.copyWith(themeMode: ThemeMode.dark));
    } else if (cached == 'light') {
      emit(state.copyWith(themeMode: ThemeMode.light));
    } else {
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }

  /// Sets the theme mode and saves the choice locally
  Future<void> setThemeMode(ThemeMode mode) async {
    emit(state.copyWith(themeMode: mode));
    String modeString;
    switch (mode) {
      case ThemeMode.dark:
        modeString = 'dark';
        break;
      case ThemeMode.light:
        modeString = 'light';
        break;
      case ThemeMode.system:
        modeString = 'system';
        break;
    }
    await CacheHelper.saveData(key: _themeCacheKey, value: modeString);
  }

  /// Toggles between Light and Dark mode
  Future<void> toggleTheme(bool isDark) async {
    final newMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  /// Checks whether dark mode is currently active (taking system brightness into account)
  bool isDarkMode(BuildContext context) {
    if (state.themeMode == ThemeMode.dark) return true;
    if (state.themeMode == ThemeMode.light) return false;
    return MediaQuery.platformBrightnessOf(context) == Brightness.dark;
  }
}
