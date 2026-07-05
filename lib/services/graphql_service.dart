import 'dart:async';

import 'package:graphql/client.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kReleaseMode, debugPrint;

import 'graph_ql_auth_session.dart';

class GraphQlUnauthorizedException implements Exception {
  final String message;

  const GraphQlUnauthorizedException(this.message);

  @override
  String toString() => message;
}

class GraphQlRequestException implements Exception {
  final String operation;
  final String message;

  const GraphQlRequestException({required this.operation, required this.message});

  @override
  String toString() => '$operation failed: $message';
}

class GraphQlService {
  final GraphQLClient client;
  static final StreamController<String> _unauthorizedController =
      StreamController<String>.broadcast();

  static Stream<String> get unauthorizedEvents => _unauthorizedController.stream;

  GraphQlService._(this.client);

  factory GraphQlService({
    required String endpoint,
    String? authToken,
    Future<String?> Function()? tokenProvider,
  }) {
    if (endpoint.isEmpty) {
      throw ArgumentError('GRAPHQL_ENDPOINT is empty.');
    }

    _validateEndpoint(endpoint);

    if (authToken != null && authToken.trim().isNotEmpty) {
      GraphQlAuthSession.setToken(authToken);
    }

    final resolvedTokenProvider = tokenProvider ?? (() async => GraphQlAuthSession.authHeader);

    Link link = AuthLink(getToken: resolvedTokenProvider).concat(
      HttpLink(
        endpoint,
        defaultHeaders: const <String, String>{
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    final client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );

    return GraphQlService._(client);
  }

  static void _validateEndpoint(String endpoint) {
    final uri = Uri.tryParse(endpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw ArgumentError('GRAPHQL_ENDPOINT is invalid: $endpoint');
    }

    final isHttps = uri.scheme.toLowerCase() == 'https';
    if (isHttps) {
      return;
    }

    final host = uri.host.toLowerCase();
    final isLocal = _isLocalHost(host);

    if (!isLocal || kReleaseMode) {
      throw ArgumentError(
        'GRAPHQL_ENDPOINT must use HTTPS in non-local environments.',
      );
    }
  }

  static bool _isLocalHost(String host) {
    if (host == 'localhost' || host == '127.0.0.1' || host == '::1') {
      return true;
    }
    // Allow LAN / private-network addresses for local dev (RFC 1918).
    if (host.startsWith('192.168.') ||
        host.startsWith('10.') ||
        host.startsWith('172.')) {
      if (kDebugMode) {
        debugPrint('[GraphQL] Using non-HTTPS LAN endpoint.');
      }
      return true;
    }
    return false;
  }

  Future<QueryResult> query({
    required String operationName,
    required String document,
    Map<String, dynamic> variables = const {},
    int maxRetries = 2,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _withRetry(
      operationName: operationName,
      maxRetries: maxRetries,
      request: () async {
        final result = await client
            .query(
              QueryOptions(
                document: gql(document),
                variables: variables,
                operationName: operationName,
                fetchPolicy: FetchPolicy.networkOnly,
              ),
            )
            .timeout(timeout);

        _throwIfException(operationName, result);
        return result;
      },
    );
  }

  Future<QueryResult> mutate({
    required String operationName,
    required String document,
    Map<String, dynamic> variables = const {},
    int maxRetries = 1,
    Duration timeout = const Duration(seconds: 15),
  }) async {
    return _withRetry(
      operationName: operationName,
      maxRetries: maxRetries,
      request: () async {
        final result = await client
            .mutate(
              MutationOptions(
                document: gql(document),
                variables: variables,
                operationName: operationName,
              ),
            )
            .timeout(timeout);

        _throwIfException(operationName, result);
        return result;
      },
    );
  }

  Future<QueryResult> _withRetry({
    required String operationName,
    required int maxRetries,
    required Future<QueryResult> Function() request,
  }) async {
    int attempt = 0;
    while (true) {
      attempt++;
      try {
        if (kDebugMode) {
          debugPrint('[GraphQL] $operationName attempt $attempt');
        }
        return await request();
      } on GraphQlUnauthorizedException {
        rethrow;
      } catch (e) {
        if (attempt > maxRetries) {
          throw GraphQlRequestException(
            operation: operationName,
            message: e.toString(),
          );
        }
      }
    }
  }

  void _throwIfException(String operationName, QueryResult result) {
    if (!result.hasException) {
      return;
    }

    final message = result.exception.toString();
    if (_isUnauthorized(result.exception)) {
      _unauthorizedController.add(operationName);
      throw GraphQlUnauthorizedException(
        'Unauthorized request during $operationName. Session may have expired.',
      );
    }

    throw GraphQlRequestException(operation: operationName, message: message);
  }

  bool _isUnauthorized(OperationException? exception) {
    if (exception == null) {
      return false;
    }

    final linkMessage = exception.linkException?.toString().toLowerCase() ?? '';
    if (linkMessage.contains('401') ||
        linkMessage.contains('unauthorized') ||
        linkMessage.contains('forbidden')) {
      return true;
    }

    for (final error in exception.graphqlErrors) {
      final code = error.extensions?['code']?.toString().toUpperCase();
      final message = error.message.toLowerCase();
      if (code == 'UNAUTHENTICATED' ||
          code == 'FORBIDDEN' ||
          message.contains('unauthorized') ||
          message.contains('authentication')) {
        return true;
      }
    }

    return false;
  }
}
