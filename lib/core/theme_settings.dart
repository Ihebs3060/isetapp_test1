import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeSettings extends ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = kPrimaryBlue;
  Color _textColor = Colors.black;
  String _language = 'Français';

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  Color get textColor => _textColor;
  String get language => _language;

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setTextColor(Color color) {
    _textColor = color;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }

  ThemeData getTheme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _primaryColor,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
      textTheme: ThemeData().textTheme.apply(
        bodyColor: _isDarkMode ? Colors.white : _textColor,
        displayColor: _isDarkMode ? Colors.white : _textColor,
      ),
    );
  }
}
