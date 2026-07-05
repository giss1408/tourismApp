import 'dto/auth_user_dto.dart';
import '../models/user_model.dart';
import '../services/graph_ql_auth_session.dart';
import '../services/graphql_service.dart';
import 'auth_repository.dart';

class ApiAuthRepository implements AuthRepository {
  final GraphQlService _graphQl;

  ApiAuthRepository({
    required String endpoint,
    String? authToken,
  }) : _graphQl = GraphQlService(endpoint: endpoint, authToken: authToken);

  @override
  Stream<AppUser?> authStateChanges() {
    // Stateless backend auth stream placeholder.
    return const Stream<AppUser?>.empty();
  }

  @override
  Future<AppUser> signInWithEmail(String email, String password) async {
    const mutation = r'''
      mutation SignIn($email: String!, $password: String!) {
        signIn(email: $email, password: $password) {
          uid
          email
          displayName
          photoURL
          provider
          createdAt
        }
      }
    ''';

    final result = await _graphQl.mutate(
      operationName: 'SignIn',
      document: mutation,
      variables: {'email': email, 'password': password},
    );

    final json = result.data?['signIn'] as Map<String, dynamic>?;
    if (json == null) {
      throw const AuthFailure('API sign-in returned empty user payload.');
    }

    GraphQlAuthSession.setToken(_extractToken(result.data, 'signIn', json));

    return AuthUserDto.fromJson(json).toDomain();
  }

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    const mutation = r'''
      mutation SignUp($email: String!, $password: String!, $displayName: String!) {
        signUp(email: $email, password: $password, displayName: $displayName) {
          uid
          email
          displayName
          photoURL
          provider
          createdAt
        }
      }
    ''';

    final result = await _graphQl.mutate(
      operationName: 'SignUp',
      document: mutation,
      variables: {
        'email': email,
        'password': password,
        'displayName': displayName,
      },
    );

    final json = result.data?['signUp'] as Map<String, dynamic>?;
    if (json == null) {
      throw const AuthFailure('API sign-up returned empty user payload.');
    }

    GraphQlAuthSession.setToken(_extractToken(result.data, 'signUp', json));

    return AuthUserDto.fromJson(json).toDomain();
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    throw const AuthFailure('Google sign-in is not yet supported by API auth mode.');
  }

  @override
  Future<AppUser> signInWithFacebook() async {
    throw const AuthFailure('Facebook sign-in is not yet supported by API auth mode.');
  }

  @override
  Future<void> updateDisplayName(String displayName) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> changePassword(String c, String n) async {}

  @override
  Future<void> signOut() async {
    const mutation = r'''
      mutation SignOut {
        signOut
      }
    ''';

    await _graphQl.mutate(
      operationName: 'SignOut',
      document: mutation,
    );
    GraphQlAuthSession.clear();
  }

  @override
  Future<void> resetPassword(String email) async {
    const mutation = r'''
      mutation ResetPassword($email: String!) {
        resetPassword(email: $email)
      }
    ''';

    await _graphQl.mutate(
      operationName: 'ResetPassword',
      document: mutation,
      variables: {'email': email},
    );
  }

  String? _extractToken(
    Map<String, dynamic>? data,
    String rootField,
    Map<String, dynamic> authPayload,
  ) {
    const tokenKeys = <String>['accessToken', 'token', 'jwt', 'idToken'];

    for (final key in tokenKeys) {
      final fromPayload = authPayload[key]?.toString();
      if (fromPayload != null && fromPayload.trim().isNotEmpty) {
        return fromPayload;
      }
    }

    final root = data?[rootField];
    if (root is Map<String, dynamic>) {
      final nestedToken = root['authToken']?.toString();
      if (nestedToken != null && nestedToken.trim().isNotEmpty) {
        return nestedToken;
      }
    }

    final topLevelKeys = <String>['accessToken', 'token', 'authToken'];
    for (final key in topLevelKeys) {
      final topLevelToken = data?[key]?.toString();
      if (topLevelToken != null && topLevelToken.trim().isNotEmpty) {
        return topLevelToken;
      }
    }

    return null;
  }

}
