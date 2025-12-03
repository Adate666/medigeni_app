import 'package:flutter/material.dart';

class UIProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool _isLoading = false;
  String? _loadingMessage;

  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  String? get loadingMessage => _loadingMessage;

  UIProvider() {
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    try {
      // Charger la préférence depuis SharedPreferences si nécessaire
      // Pour l'instant, on utilise le mode système par défaut
    } catch (e) {
      debugPrint('Error loading theme preference: $e');
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  void setLoading(bool value, {String? message}) {
    _isLoading = value;
    _loadingMessage = message;
    notifyListeners();
  }

  void clearLoading() {
    _isLoading = false;
    _loadingMessage = null;
    notifyListeners();
  }
}

