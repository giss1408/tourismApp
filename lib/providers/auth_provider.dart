// providers/auth_provider.dart - Fix Facebook login for version 7.1.0
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode, ChangeNotifier, debugPrint;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  AppUser? _user;
  bool _isLoading = false;
  String _error = '';

  AppUser? get user => _user;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      // Listen to auth state changes
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user != null) {
          _user = AppUser.fromFirebase(user);
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
      await prefs.setString('user_uid', _user!.uid);
      await prefs.setString('user_email', _user!.email ?? '');
      await prefs.setString('user_displayName', _user!.displayName ?? '');
      await prefs.setString('user_photoURL', _user!.photoURL ?? '');
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

      // DEV bypass: create a local dummy user in debug mode
      if (kDebugMode) {
        _user = AppUser(
          uid: 'dev_user',
          email: email,
          displayName: displayName,
          photoURL: null,
        );
        await _saveUserToPrefs();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      final UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Update display name
      await userCredential.user!.updateDisplayName(displayName);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
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

      // DEV bypass: sign in locally in debug mode
      if (kDebugMode) {
        _user = AppUser(
          uid: 'dev_user',
          email: email,
          displayName: 'Dev User',
          photoURL: null,
        );
        await _saveUserToPrefs();
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'An unexpected error occurred: $e';
      notifyListeners();
      return false;
    }
  }

  // Google Sign In
  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // DEV bypass for web/mobile in debug mode
      if (kDebugMode) {
        _user = AppUser(
          uid: 'dev_google',
          email: 'dev_google@example.com',
          displayName: 'Dev Google',
          photoURL: null,
        );
        await _saveUserToPrefs();
        _isLoading = false;
        notifyListeners();
        return true;
      }

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final UserCredential cred = await FirebaseAuth.instance.signInWithPopup(provider);
        final firebaseUser = cred.user;
        if (firebaseUser != null) {
          _user = AppUser.fromFirebase(firebaseUser); // or construct as before
          await _saveUserToPrefs();
          _isLoading = false;
          notifyListeners();
          return true;
        }
        _isLoading = false;
        _error = 'Google sign-in failed: no user returned';
        notifyListeners();
        return false;
      } else {
        // mobile/desktop path using google_sign_in package
        final googleSignIn = GoogleSignIn(
          clientId: kIsWeb
              ? '122218319110-k53aan9f4qbof5a3rp43501v7eq9g7ei.apps.googleusercontent.com'
              : null,
          scopes: ['email', 'profile'],
        );
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        final UserCredential cred = await FirebaseAuth.instance.signInWithCredential(credential);
        final firebaseUser = cred.user;
        if (firebaseUser != null) {
          _user = AppUser(
            uid: firebaseUser.uid,
            email: firebaseUser.email,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
          );
          await _saveUserToPrefs();
          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          _error = 'Google sign-in failed';
          notifyListeners();
          return false;
        }
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint('Google signIn FirebaseAuthException: ${e.code} / ${e.message}\n$st');
      _isLoading = false;
      _error = e.message ?? 'FirebaseAuthException: ${e.code}';
      notifyListeners();
      return false;
    } catch (e, st) {
      debugPrint('Google signIn error: $e\n$st');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Facebook Sign In - FIXED for various flutter_facebook_auth/web shapes
  Future<bool> signInWithFacebook() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // accessToken shape varies across platforms/versions.
        // Use dynamic lookup to avoid compile-time getter errors.
        final access = result.accessToken;
        final dyn = access as dynamic?;
        final String? token = dyn == null
            ? null
            : (dyn.tokenString ?? dyn.token ?? dyn.accessToken ?? dyn.value) as String?;

        if (token != null) {
          final OAuthCredential credential = FacebookAuthProvider.credential(token);
          await FirebaseAuth.instance.signInWithCredential(credential);

          _isLoading = false;
          notifyListeners();
          return true;
        } else {
          _isLoading = false;
          _error = 'Failed to get Facebook access token';
          notifyListeners();
          return false;
        }
      } else {
        _isLoading = false;
        _error = 'Facebook login cancelled';
        notifyListeners();
        return false;
      }
    } on FirebaseAuthException catch (e, st) {
      debugPrint('Facebook signIn FirebaseAuthException: ${e.code} / ${e.message}\n$st');
      _isLoading = false;
      _error = e.message ?? 'FirebaseAuthException: ${e.code}';
      notifyListeners();
      return false;
    } catch (e, st) {
      debugPrint('Facebook signIn error: $e\n$st');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to sign out: $e';
      notifyListeners();
    }
  }

  // Reset Password
  Future<bool> resetPassword(String email) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _isLoading = false;
      _error = _getAuthErrorMessage(e);
      notifyListeners();
      return false;
    } catch (e) {
      _isLoading = false;
      _error = 'Failed to reset password: $e';
      notifyListeners();
      return false;
    }
  }

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}