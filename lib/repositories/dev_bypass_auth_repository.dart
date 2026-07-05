import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;

import '../models/user_model.dart';
import 'auth_repository.dart';

/// Drop-in [AuthRepository] that immediately signs in a fake dev user.
/// Only compiled in when [kDebugMode] is true and the dart-define
/// `DEV_AUTO_LOGIN=true` is set. Never used in release builds.
class DevBypassAuthRepository implements AuthRepository {
  static const bool _enabled =
      bool.fromEnvironment('DEV_AUTO_LOGIN', defaultValue: false);

  static bool get isEnabled => kDebugMode && _enabled;

  static final AppUser _devUser = AppUser(
    uid: 'dev-bypass-uid',
    email: 'dev@local.test',
    displayName: 'Dev User',
    provider: 'dev',
  );

  final _controller = StreamController<AppUser?>.broadcast();

  DevBypassAuthRepository() {
    // Emit the dev user on the next microtask so listeners are attached first.
    Future.microtask(() => _controller.add(_devUser));
  }

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async =>
      _devUser;

  @override
  Future<AppUser> signUpWithEmail(
          String email, String password, String displayName) async =>
      _devUser;

  @override
  Future<AppUser> signInWithGoogle() async => _devUser;

  @override
  Future<AppUser> signInWithFacebook() async => _devUser;

  @override
  Future<void> signOut() async => _controller.add(null);

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> changePassword(String c, String n) async {}
}
