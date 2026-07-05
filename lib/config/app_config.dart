class AppConfig {
  final bool useGraphQlApi;
  final String graphQlEndpoint;
  final String graphQlAuthToken;

  const AppConfig({
    required this.useGraphQlApi,
    required this.graphQlEndpoint,
    required this.graphQlAuthToken,
  });

  factory AppConfig.fromEnvironment() {
    return AppConfig.fromValues(
      useGraphQlApi: const bool.fromEnvironment(
        'USE_GRAPHQL_API',
        defaultValue: false,
      ),
      graphQlEndpoint: const String.fromEnvironment('GRAPHQL_ENDPOINT'),
      graphQlAuthToken: const String.fromEnvironment('GRAPHQL_AUTH_TOKEN'),
    );
  }

  factory AppConfig.fromValues({
    required bool useGraphQlApi,
    required String graphQlEndpoint,
    required String graphQlAuthToken,
  }) {
    return AppConfig(
      useGraphQlApi: useGraphQlApi,
      graphQlEndpoint: graphQlEndpoint.trim(),
      graphQlAuthToken: graphQlAuthToken.trim(),
    );
  }

  void validate() {
    if (useGraphQlApi && graphQlEndpoint.isEmpty) {
      throw StateError(
        'USE_GRAPHQL_API=true requires GRAPHQL_ENDPOINT to be set.',
      );
    }

    if (!useGraphQlApi || graphQlEndpoint.isEmpty) {
      return;
    }

    final uri = Uri.tryParse(graphQlEndpoint);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('GRAPHQL_ENDPOINT is invalid.');
    }

    final isHttps = uri.scheme.toLowerCase() == 'https';
    final host = uri.host.toLowerCase();
    final isLocal = _isLocalHost(host);

    if (!isHttps && !isLocal) {
      throw StateError('GRAPHQL_ENDPOINT must use HTTPS for non-local environments.');
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
      return true;
    }
    return false;
  }
}
