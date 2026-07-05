import '../models/user_model.dart';

class AuthFailure implements Exception {
  final String message;

  const AuthFailure(this.message);

  @override
  String toString() => message;
}

abstract class AuthRepository {
  Stream<AppUser?> authStateChanges();
  Future<AppUser> signUpWithEmail(String email, String password, String displayName);
  Future<AppUser> signInWithEmail(String email, String password);
  Future<AppUser> signInWithGoogle();
  Future<AppUser> signInWithFacebook();
  Future<void> signOut();
  Future<void> resetPassword(String email);

  // Optional Firebase-specific profile management — default no-ops for other providers
  Future<void> updateDisplayName(String displayName) =>
      Future<void>.value();
  Future<void> sendEmailVerification() =>
      Future<void>.value();
  Future<void> changePassword(String currentPassword, String newPassword) =>
      Future<void>.value();
}
