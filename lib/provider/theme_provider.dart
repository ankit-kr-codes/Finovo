import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Enum for selecting AppTheme
enum AppTheme { system, light, dark }

class ThemeProvider extends ChangeNotifier {
  // Default theme follows system settings
  ThemeMode _themeMode = ThemeMode.system;

  //Getter
  ThemeMode get themeMode => _themeMode;

  //Constructor
  ThemeProvider() {
    _loadTheme();
  }

  //This function loads the saved theme by using shared preferences
  Future<void> _loadTheme() async {
    var prefs = await SharedPreferences.getInstance();
    int? savedTheme = prefs.getInt('themeMode');

    if (savedTheme != null) {
      ThemeMode newThemeMode;
      switch (AppTheme.values[savedTheme]) {
        case AppTheme.light:
          newThemeMode = ThemeMode.light;
          break;
        case AppTheme.dark:
          newThemeMode = ThemeMode.dark;
          break;
        default:
          newThemeMode = ThemeMode.system;
      }

      if (_themeMode != newThemeMode) {
        _themeMode = newThemeMode;
        notifyListeners();
      }
    }
  }

  //This function change theme as per user's instruction
  Future<void> setTheme(AppTheme theme) async {
    ThemeMode newThemeMode;
    switch (theme) {
      case AppTheme.light:
        newThemeMode = ThemeMode.light;
        break;
      case AppTheme.dark:
        newThemeMode = ThemeMode.dark;
        break;
      default:
        newThemeMode = ThemeMode.system;
    }

    if (_themeMode != newThemeMode) {
      _themeMode = newThemeMode;
      notifyListeners();
    }

    var prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', theme.index);
  }
}
