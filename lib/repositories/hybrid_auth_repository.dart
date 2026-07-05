import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;

import '../models/user_model.dart';
import '../services/graph_ql_auth_session.dart';
import '../services/graphql_service.dart';
import 'auth_repository.dart';
import 'dto/auth_user_dto.dart';
import 'firebase_auth_repository.dart';

class HybridAuthRepository implements AuthRepository {
  final FirebaseAuthRepository _firebase;
  final GraphQlService _graphQl;

  HybridAuthRepository({
    required String endpoint,
    String? authToken,
  })  : _firebase = const FirebaseAuthRepository(),
        _graphQl = GraphQlService(endpoint: endpoint, authToken: authToken);

  @override
  Stream<AppUser?> authStateChanges() => const Stream<AppUser?>.empty();

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    const mutation = r'''
      mutation SignIn($email: String!, $password: String!) {
        signIn(email: $email, password: $password) {
          uid email displayName photoURL provider createdAt accessToken
        }
      }
    ''';
    final result = await _graphQl.mutate(
      operationName: 'SignIn',
      document: mutation,
      variables: {'email': email, 'password': password},
    );
    final json = result.data?['signIn'] as Map<String, dynamic>?;
    if (json == null) throw const AuthFailure('Sign-in returned empty payload.');
    _storeToken(json, result.data);
    return AuthUserDto.fromJson(json).toDomain();
  }

  @override
  Future<AppUser> signUpWithEmail(String email, String password, String displayName) async {
    const mutation = r'''
      mutation SignUp($email: String!, $password: String!, $displayName: String!) {
        signUp(email: $email, password: $password, displayName: $displayName) {
          uid email displayName photoURL provider createdAt accessToken
        }
      }
    ''';
    final result = await _graphQl.mutate(
      operationName: 'SignUp',
      document: mutation,
      variables: {'email': email, 'password': password, 'displayName': displayName},
    );
    final json = result.data?['signUp'] as Map<String, dynamic>?;
    if (json == null) throw const AuthFailure('Sign-up returned empty payload.');
    _storeToken(json, result.data);
    return AuthUserDto.fromJson(json).toDomain();
  }

  @override
  Future<void> signOut() async {
    try {
      const mutation = r'''mutation SignOut { signOut }''';
      await _graphQl.mutate(operationName: 'SignOut', document: mutation);
    } catch (_) {}
    GraphQlAuthSession.clear();
    await _firebase.signOut().catchError((_) {});
  }

  @override
  Future<void> resetPassword(String email) async {
    const mutation = r'''
      mutation ResetPassword($email: String!) { resetPassword(email: $email) }
    ''';
    await _graphQl.mutate(
      operationName: 'ResetPassword',
      document: mutation,
      variables: {'email': email},
    );
  }

  // Delegate profile management to Firebase (requires Firebase sign-in)
  @override
  Future<void> updateDisplayName(String displayName) =>
      _firebase.updateDisplayName(displayName);

  @override
  Future<void> sendEmailVerification() =>
      _firebase.sendEmailVerification();

  @override
  Future<void> changePassword(String currentPassword, String newPassword) =>
      _firebase.changePassword(currentPassword, newPassword);

  @override
  Future<AppUser> signInWithGoogle() async {
    final firebaseUser = await _firebase.signInWithGoogle();
    if (kDebugMode) debugPrint('[HybridAuth] Google Firebase user: ${firebaseUser.uid}');
    return _socialSignIn(firebaseUser);
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    final firebaseUser = await _firebase.signInWithFacebook();
    if (kDebugMode) debugPrint('[HybridAuth] Facebook Firebase user: ${firebaseUser.uid}');
    return _socialSignIn(firebaseUser);
  }

  Future<AppUser> _socialSignIn(AppUser firebaseUser) async {
    if (kDebugMode) {
      debugPrint('[HybridAuth] _socialSignIn uid=${firebaseUser.uid} email=${firebaseUser.email}');
    }

    const mutation = r'''
      mutation SocialSignIn(
        $uid: String!
        $email: String!
        $displayName: String
        $photoURL: String
        $provider: String!
      ) {
        socialSignIn(
          uid: $uid
          email: $email
          displayName: $displayName
          photoURL: $photoURL
          provider: $provider
        ) {
          uid email displayName photoURL provider createdAt accessToken
        }
      }
    ''';

    try {
      final result = await _graphQl.mutate(
        operationName: 'SocialSignIn',
        document: mutation,
        variables: {
          'uid': firebaseUser.uid,
          'email': (firebaseUser.email?.isNotEmpty == true)
              ? firebaseUser.email
              : '${firebaseUser.uid}@social.local',
          'displayName': firebaseUser.displayName,
          'photoURL': firebaseUser.photoURL,
          'provider': firebaseUser.provider ?? 'google',
        },
      );

      if (kDebugMode) {
        debugPrint('[HybridAuth] socialSignIn data=${result.data}');
        debugPrint('[HybridAuth] socialSignIn exception=${result.exception}');
      }

      final json = result.data?['socialSignIn'] as Map<String, dynamic>?;
      if (json == null) {
        throw const AuthFailure('Social sign-in: empty response from backend.');
      }

      _storeToken(json, result.data);
      return AuthUserDto.fromJson(json).toDomain();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[HybridAuth] _socialSignIn ERROR: $e');
        debugPrint('[HybridAuth] _socialSignIn TRACE: $st');
      }
      rethrow;
    }
  }

  void _storeToken(Map<String, dynamic> payload, Map<String, dynamic>? data) {
    final token = payload['accessToken']?.toString()
        ?? payload['token']?.toString()
        ?? data?['accessToken']?.toString();
    if (token != null && token.trim().isNotEmpty) {
      GraphQlAuthSession.setToken(token);
    }
  }
}
