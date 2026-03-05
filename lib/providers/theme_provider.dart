import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

//theme mode state notifier
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  //load saved theme preference
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeString = prefs.getString('theme_mode') ?? 'system';

    state = _stringToThemeMode(themeString);
  }

  //save theme preference
  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));
  }

  //toggle between light and dark
  void toggleTheme() {
    if (state == ThemeMode.light) {
      setTheme(ThemeMode.dark);
    } else {
      setTheme(ThemeMode.light);
    }
  }

  //set specific theme
  void setTheme(ThemeMode mode) {
    state = mode;
    _saveTheme(mode);
  }

  //conversting themeMode to string
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  //converting string to themeMode
  ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

//provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});