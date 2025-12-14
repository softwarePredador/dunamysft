import 'package:flutter/foundation.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  /// Toggles between light and dark theme
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Sets the theme mode explicitly
  void setThemeMode(bool isDark) {
    _isDarkMode = isDark;
    notifyListeners();
  }
}
