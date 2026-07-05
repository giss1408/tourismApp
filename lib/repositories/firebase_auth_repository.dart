import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository();

  @override
  Stream<AppUser?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AppUser.fromFirebase(user);
    });
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    if (kDebugMode) {
      return AppUser(
        uid: 'dev_user',
        email: email,
        displayName: displayName,
      );
    }

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthFailure('Failed to create account.');
      }

      await firebaseUser.updateDisplayName(displayName);
      await firebaseUser.reload();
      final refreshedUser = FirebaseAuth.instance.currentUser;
      if (refreshedUser == null) {
        throw const AuthFailure('Failed to refresh user profile.');
      }

      return AppUser.fromFirebase(refreshedUser);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    } catch (e) {
      throw AuthFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    if (kDebugMode) {
      return AppUser(
        uid: 'dev_user',
        email: email,
        displayName: 'Dev User',
      );
    }

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('Sign in failed: no user returned.');
      }
      return AppUser.fromFirebase(user);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    } catch (e) {
      throw AuthFailure('An unexpected error occurred: $e');
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        final cred = await FirebaseAuth.instance.signInWithPopup(provider);
        final user = cred.user;
        if (user == null) {
          throw const AuthFailure('Google sign-in failed: no user returned.');
        }
        return AppUser.fromFirebase(user);
      }

      final googleSignIn = GoogleSignIn(scopes: const ['email', 'profile']);
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw const AuthFailure('Google sign-in cancelled.');
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('Google sign-in failed.');
      }

      return AppUser.fromFirebase(user);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('Google signIn FirebaseAuthException: ${e.code} / ${e.message}\n$st');
      throw AuthFailure(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('Google signIn error: $e\n$st');
      if (e is AuthFailure) {
        rethrow;
      }
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    if (kDebugMode) {
      throw const AuthFailure(
        'Facebook sign-in is not configured yet.\n'
        'Set up a Facebook App ID in AndroidManifest.xml to enable it.',
      );
    }

    try {
      final result = await FacebookAuth.instance.login();
      if (result.status != LoginStatus.success) {
        throw const AuthFailure('Facebook login cancelled.');
      }

      final access = result.accessToken;
      final dyn = access as dynamic;
      final String? token =
          (dyn.tokenString ?? dyn.token ?? dyn.accessToken ?? dyn.value) as String?;
      if (token == null || token.isEmpty) {
        throw const AuthFailure('Failed to get Facebook access token.');
      }

      final credential = FacebookAuthProvider.credential(token);
      final cred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = cred.user;
      if (user == null) {
        throw const AuthFailure('Facebook sign-in failed.');
      }

      return AppUser.fromFirebase(user);
    } on FirebaseAuthException catch (e, st) {
      debugPrint('Facebook signIn FirebaseAuthException: ${e.code} / ${e.message}\n$st');
      throw AuthFailure(_mapFirebaseError(e));
    } catch (e, st) {
      debugPrint('Facebook signIn error: $e\n$st');
      if (e is AuthFailure) {
        rethrow;
      }
      throw AuthFailure(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await GoogleSignIn().signOut();
      await FacebookAuth.instance.logOut();
    } catch (e) {
      throw AuthFailure('Failed to sign out: $e');
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    } catch (e) {
      throw AuthFailure('Failed to reset password: $e');
    }
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AuthFailure('Not signed in.');
    try {
      await user.updateDisplayName(displayName.trim());
      await user.reload();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AuthFailure('Not signed in.');
    if (user.emailVerified) throw const AuthFailure('Email is already verified.');
    try {
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw const AuthFailure('Not signed in.');
    if (user.email == null) {
      throw const AuthFailure('Password change is not available for social accounts.');
    }
    try {
      // Re-authenticate before changing password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthFailure(_mapFirebaseError(e));
    }
  }

  String _mapFirebaseError(FirebaseAuthException e) {
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
}
