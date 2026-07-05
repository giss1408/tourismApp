import 'dart:async';

import 'package:explore_world/models/user_model.dart';
import 'package:explore_world/providers/auth_provider.dart';
import 'package:explore_world/repositories/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeAuthRepository implements AuthRepository {
  final StreamController<AppUser?> _controller =
      StreamController<AppUser?>.broadcast();

  AppUser? _current;

  @override
  Stream<AppUser?> authStateChanges() => _controller.stream;

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    _current = AppUser(uid: 'u1', email: email, displayName: 'User');
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _current = AppUser(uid: 'u2', email: email, displayName: displayName);
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    _current = AppUser(
      uid: 'google_1',
      email: 'g@example.com',
      displayName: 'Google User',
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    _current = AppUser(
      uid: 'fb_1',
      email: 'f@example.com',
      displayName: 'Facebook User',
    );
    _controller.add(_current);
    return _current!;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> updateDisplayName(String displayName) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> changePassword(String c, String n) async {}

  Future<void> dispose() async {
    await _controller.close();
  }
}

class _ThrowingAuthRepository implements AuthRepository {
  @override
  Stream<AppUser?> authStateChanges() => const Stream<AppUser?>.empty();

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    throw const AuthFailure('Bad credentials');
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    throw const AuthFailure('Registration failed');
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    throw const AuthFailure('Google disabled');
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    throw const AuthFailure('Facebook disabled');
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {
    throw const AuthFailure('Reset failed');
  }

  @override
  Future<void> updateDisplayName(String displayName) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> changePassword(String c, String n) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('AuthProvider signs in and updates login state', () async {
    final repo = _FakeAuthRepository();
    final provider = AuthProvider(repository: repo);

    final success = await provider.signInWithEmail('mail@example.com', '123456');
    await Future<void>.delayed(Duration.zero);

    expect(success, isTrue);
    expect(provider.isLoggedIn, isTrue);
    expect(provider.user?.email, 'mail@example.com');
    expect(provider.error, isEmpty);

    await repo.dispose();
    provider.dispose();
  });

  test('AuthProvider exposes repository auth errors', () async {
    final provider = AuthProvider(repository: _ThrowingAuthRepository());

    final success = await provider.signInWithEmail('mail@example.com', 'bad');

    expect(success, isFalse);
    expect(provider.isLoggedIn, isFalse);
    expect(provider.error, 'Bad credentials');

    provider.dispose();
  });

  test('AuthProvider stores only minimal user marker in prefs', () async {
    final repo = _FakeAuthRepository();
    final provider = AuthProvider(repository: repo);

    final success = await provider.signInWithEmail('mail@example.com', '123456');
    expect(success, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_uid'), isNotEmpty);
    expect(prefs.getString('user_email'), isNull);
    expect(prefs.getString('user_displayName'), isNull);
    expect(prefs.getString('user_photoURL'), isNull);

    await repo.dispose();
    provider.dispose();
  });

  test('AuthProvider clears persisted marker on signOut', () async {
    final repo = _FakeAuthRepository();
    final provider = AuthProvider(repository: repo);

    await provider.signInWithEmail('mail@example.com', '123456');
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('user_uid'), isNotNull);

    await provider.signOut();
    prefs = await SharedPreferences.getInstance();
    expect(provider.isLoggedIn, isFalse);
    expect(prefs.getString('user_uid'), isNull);

    await repo.dispose();
    provider.dispose();
  });
}
