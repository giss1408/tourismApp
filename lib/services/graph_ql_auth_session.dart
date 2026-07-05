class GraphQlAuthSession {
  static String? _bearerToken;

  static String? get bearerToken => _bearerToken;

  static String? get authHeader {
    final token = _sanitizeToken(_bearerToken);
    if (token == null) {
      return null;
    }
    return 'Bearer $token';
  }

  static void setToken(String? token) {
    _bearerToken = _sanitizeToken(token);
  }

  static void clear() {
    _bearerToken = null;
  }

  static String? _sanitizeToken(String? token) {
    if (token == null) {
      return null;
    }

    final trimmed = token.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    if (trimmed.toLowerCase().startsWith('bearer ')) {
      final withoutPrefix = trimmed.substring(7).trim();
      return withoutPrefix.isEmpty ? null : withoutPrefix;
    }

    return trimmed;
  }
}
