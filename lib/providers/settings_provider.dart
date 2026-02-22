import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  // Settings state
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _locationAccess = false;
  String _selectedLanguage = 'العربية';
  double _fontSize = 16.0;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _theme = 'system'; // system, light, dark

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get locationAccess => _locationAccess;
  String get selectedLanguage => _selectedLanguage;
  double get fontSize => _fontSize;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  String get theme => _theme;

  final List<String> languages = ['العربية', 'English', 'Français', 'Español'];
  final List<String> themes = ['system', 'light', 'dark'];

  SettingsProvider() {
    _loadSettings();
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _locationAccess = prefs.getBool('locationAccess') ?? false;
    _selectedLanguage = prefs.getString('selectedLanguage') ?? 'العربية';
    _fontSize = prefs.getDouble('fontSize') ?? 16.0;
    _soundEnabled = prefs.getBool('soundEnabled') ?? true;
    _vibrationEnabled = prefs.getBool('vibrationEnabled') ?? true;
    _theme = prefs.getString('theme') ?? 'system';
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setBool('notificationsEnabled', _notificationsEnabled);
    await prefs.setBool('locationAccess', _locationAccess);
    await prefs.setString('selectedLanguage', _selectedLanguage);
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setBool('soundEnabled', _soundEnabled);
    await prefs.setBool('vibrationEnabled', _vibrationEnabled);
    await prefs.setString('theme', _theme);
  }

  // Setters with persistence
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setLocationAccess(bool value) async {
    _locationAccess = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSelectedLanguage(String value) async {
    _selectedLanguage = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setFontSize(double value) async {
    _fontSize = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    _theme = value;
    if (value == 'dark') {
      _isDarkMode = true;
    } else if (value == 'light') {
      _isDarkMode = false;
    }
    await _saveSettings();
    notifyListeners();
  }

  // Get theme mode for MaterialApp
  ThemeMode get themeMode {
    switch (_theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Reset all settings to default
  Future<void> resetSettings() async {
    _isDarkMode = false;
    _notificationsEnabled = true;
    _locationAccess = false;
    _selectedLanguage = 'العربية';
    _fontSize = 16.0;
    _soundEnabled = true;
    _vibrationEnabled = true;
    _theme = 'system';
    await _saveSettings();
    notifyListeners();
  }
}
