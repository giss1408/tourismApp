import 'dart:async';

import 'package:flutter/foundation.dart' show ChangeNotifier, kDebugMode, debugPrint;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';
import '../services/graph_ql_auth_session.dart';
import '../services/graphql_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;
  StreamSubscription<String>? _sessionSubscription;

  AppUser? _user;
  bool _isLoading = false;
  String _error = '';

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider({AuthRepository? repository})
      : _repository = repository ?? const FirebaseAuthRepository() {
    _initializeAuth();
    _initializeSessionEvents();
  }

  void _initializeSessionEvents() {
    _sessionSubscription = GraphQlService.unauthorizedEvents.listen((_) async {
      _user = null;
      _error = 'Session expired. Please sign in again.';
      GraphQlAuthSession.clear();
      await _clearUserFromPrefs();
      notifyListeners();
    });
  }

  Future<void> _initializeAuth() async {
    try {
      _authSubscription = _repository.authStateChanges().listen((user) {
        if (user != null) {
          _user = user;
          _saveUserToPrefs();
        } else {
          _user = null;
          _clearUserFromPrefs();
        }
        notifyListeners();
      });
    } catch (e) {
      _error = 'Failed to initialize auth: $e';
      notifyListeners();
    }
  }

  Future<void> _saveUserToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (_user != null) {
      // Persist only a minimal marker; avoid storing profile PII in plaintext prefs.
      await prefs.setString('user_uid', _user!.uid);
    }
  }

  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.remove('user_email');
    await prefs.remove('user_displayName');
    await prefs.remove('user_photoURL');
  }

  // Email/Password Sign Up
  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _user = await _repository.signUpWithEmail(email, password, displayName);
      await _saveUserToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  // Email/Password Sign In
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _user = await _repository.signInWithEmail(email, password);
      await _saveUserToPrefs();
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      _user = await _repository.signInWithGoogle();
      await _saveUserToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e, st) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('[AuthProvider] signInWithGoogle error: $e');
        debugPrint('[AuthProvider] signInWithGoogle trace: $st');
      }
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithFacebook() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      _user = await _repository.signInWithFacebook();
      await _saveUserToPrefs();
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e, st) {
      _isLoading = false;
      _error = e.toString();
      if (kDebugMode) {
        debugPrint('[AuthProvider] signInWithFacebook error: $e');
        debugPrint('[AuthProvider] signInWithFacebook trace: $st');
      }
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _repository.signOut();
      GraphQlAuthSession.clear();
      _user = null;
      await _clearUserFromPrefs();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await _repository.resetPassword(email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reset password: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    if (displayName.trim().isEmpty) return false;
    try {
      await _repository.updateDisplayName(displayName.trim());
      if (_user != null) {
        _user = AppUser(
          uid: _user!.uid,
          email: _user!.email,
          displayName: displayName.trim(),
          photoURL: _user!.photoURL,
          provider: _user!.provider,
          createdAt: _user!.createdAt,
        );
      }
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _repository.sendEmailVerification();
      return true;
    } on AuthFailure catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();
      await _repository.changePassword(currentPassword, newPassword);
      _isLoading = false;
      notifyListeners();
      return true;
    } on AuthFailure catch (e) {
      _isLoading = false;
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _sessionSubscription?.cancel();
    super.dispose();
  }
}