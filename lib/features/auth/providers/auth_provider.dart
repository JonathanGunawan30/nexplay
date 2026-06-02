import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.userStream.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authService.signInWithGoogle();
    if (result == null && _user == null) {
      _errorMessage = 'Login with Google was cancelled or failed.';
    }
    _setLoading(false);
  }

  Future<void> signInWithGitHub() async {
    _setLoading(true);
    _errorMessage = null;
    final result = await _authService.signInWithGitHub();
    if (result == null && _user == null) {
      _errorMessage = 'Login with GitHub was cancelled or failed.';
    }
    _setLoading(false);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
