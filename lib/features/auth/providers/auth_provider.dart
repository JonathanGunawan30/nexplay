import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/auth_service.dart';
import '../../../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription<UserModel?>? _userModelSubscription;

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.userStream.listen((User? user) {
      _user = user;
      if (user != null) {
        _subscribeToUserModel(user.uid);
      } else {
        _userModel = null;
        _userModelSubscription?.cancel();
      }
      notifyListeners();
    });
  }

  void _subscribeToUserModel(String uid) {
    _userModelSubscription?.cancel();
    _userModelSubscription = _authService.getUserDataStream(uid).listen((model) {
      _userModel = model;
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
    _userModelSubscription?.cancel();
    await _authService.signOut();
  }

  Future<bool> addPurchasedGame(String gameId) async {
    if (_user == null) return false;
    _setLoading(true);
    try {
      await _authService.addPurchasedGame(_user!.uid, gameId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update purchased games.';
      _setLoading(false);
      return false;
    }
  }

  // ponytail: Expose method to store transaction details via authProvider
  Future<bool> addTransaction({
    required String gameId,
    required String gameTitle,
    required double amount,
    required String currency,
    required String pdfUrl,
  }) async {
    if (_user == null) return false;
    try {
      await _authService.addTransaction(
        _user!.uid,
        gameId: gameId,
        gameTitle: gameTitle,
        amount: amount,
        currency: currency,
        pdfUrl: pdfUrl,
      );
      return true;
    } catch (e) {
      _errorMessage = 'Failed to save transaction history.';
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _userModelSubscription?.cancel();
    super.dispose();
  }
}
