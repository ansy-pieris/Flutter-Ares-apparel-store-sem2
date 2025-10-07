import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider class to manage app theme state (light/dark mode)
/// Handles theme switching, system theme detection, and theme persistence
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _useSystemTheme = true;

  // Getters for accessing theme state
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;
  bool get useSystemTheme => _useSystemTheme;

  /// Initialize theme state from SharedPreferences
  /// Loads user's preferred theme setting
  Future<void> initializeThemeState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedThemeIndex = prefs.getInt('themeMode') ?? 0;
    _useSystemTheme = prefs.getBool('useSystemTheme') ?? true;

    // Convert saved index back to ThemeMode
    switch (savedThemeIndex) {
      case 0:
        _themeMode = ThemeMode.system;
        break;
      case 1:
        _themeMode = ThemeMode.light;
        break;
      case 2:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }

    notifyListeners();
  }

  /// Toggle between light and dark theme
  /// If currently using system theme, switches to manual control
  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.system) {
      // Get current system brightness to decide toggle direction
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _themeMode =
          brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
    } else if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }

    _useSystemTheme = false;

    // Save theme preference
    await prefs.setInt('themeMode', _themeMode.index);
    await prefs.setBool('useSystemTheme', false);

    notifyListeners();
  }

  /// Set specific theme mode (light, dark, or system)
  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = mode;
    _useSystemTheme = mode == ThemeMode.system;

    // Save theme preference
    await prefs.setInt('themeMode', mode.index);
    await prefs.setBool('useSystemTheme', _useSystemTheme);

    notifyListeners();
  }

  /// Enable system theme following
  /// App will automatically switch based on system settings
  Future<void> enableSystemTheme() async {
    final prefs = await SharedPreferences.getInstance();

    _themeMode = ThemeMode.system;
    _useSystemTheme = true;

    await prefs.setInt('themeMode', ThemeMode.system.index);
    await prefs.setBool('useSystemTheme', true);

    notifyListeners();
  }

  /// Get theme display name for UI
  String get themeDisplayName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
}
