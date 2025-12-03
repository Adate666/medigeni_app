import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/mock_data_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadSession();
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId != null) {
        final user = MockDataService.getUserById(userId);
        if (user != null) {
          _currentUser = user;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error loading session: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulation délai

      final user = MockDataService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _errorMessage = null;

        // Sauvegarder la session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Email ou mot de passe incorrect';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? phone,
    String? address,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulation délai

      final user = MockDataService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
        address: address,
      );

      if (user != null) {
        _currentUser = user;
        _errorMessage = null;

        // Sauvegarder la session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userId', user.id);

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Cet email est déjà utilisé';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Une erreur est survenue: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _errorMessage = null;

    // Supprimer la session
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

