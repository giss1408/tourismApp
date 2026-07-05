import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;

import 'analytics_service.dart';
import 'graphql_service.dart';

typedef AnalyticsMutate = Future<void> Function({
  required String operationName,
  required String document,
  Map<String, dynamic> variables,
});

class ApiAnalyticsService implements AnalyticsService {
  static const String _trackEventMutation = r'''
    mutation TrackAnalyticsEvent($input: AnalyticsEventInput!) {
      trackAnalyticsEvent(input: $input)
    }
  ''';

  static const String _trackEventFallbackMutation = r'''
    mutation LogAnalyticsEvent($input: AnalyticsEventInput!) {
      logAnalyticsEvent(input: $input)
    }
  ''';

  static const String _setUserPropertiesMutation = r'''
    mutation SetAnalyticsUserProperties($properties: JSON!) {
      setAnalyticsUserProperties(properties: $properties)
    }
  ''';

  static const String _setUserPropertiesFallbackMutation = r'''
    mutation UpdateAnalyticsUserProperties($properties: JSON!) {
      updateAnalyticsUserProperties(properties: $properties)
    }
  ''';

  final AnalyticsMutate _mutate;

  ApiAnalyticsService({
    required String endpoint,
    String? authToken,
    AnalyticsMutate? mutate,
  }) : _mutate = mutate ?? _defaultMutate(endpoint: endpoint, authToken: authToken);

  static AnalyticsMutate _defaultMutate({
    required String endpoint,
    String? authToken,
  }) {
    final graphQl = GraphQlService(endpoint: endpoint, authToken: authToken);
    return ({
      required String operationName,
      required String document,
      Map<String, dynamic> variables = const {},
    }) {
      return graphQl.mutate(
        operationName: operationName,
        document: document,
        variables: variables,
      );
    };
  }

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    final payload = <String, dynamic>{
      'name': name,
      'properties': Map<String, Object?>.from(properties),
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    };

    await _sendWithFallback(
      candidates: const <_MutationCandidate>[
        _MutationCandidate(
          operationName: 'TrackAnalyticsEvent',
          document: _trackEventMutation,
        ),
        _MutationCandidate(
          operationName: 'LogAnalyticsEvent',
          document: _trackEventFallbackMutation,
        ),
      ],
      variables: <String, dynamic>{'input': payload},
      debugName: 'trackEvent',
    );
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {
    final payload = Map<String, Object?>.from(properties);

    await _sendWithFallback(
      candidates: const <_MutationCandidate>[
        _MutationCandidate(
          operationName: 'SetAnalyticsUserProperties',
          document: _setUserPropertiesMutation,
        ),
        _MutationCandidate(
          operationName: 'UpdateAnalyticsUserProperties',
          document: _setUserPropertiesFallbackMutation,
        ),
      ],
      variables: <String, dynamic>{'properties': payload},
      debugName: 'setUserProperties',
    );
  }

  Future<void> _sendWithFallback({
    required List<_MutationCandidate> candidates,
    required Map<String, dynamic> variables,
    required String debugName,
  }) async {
    Object? lastError;

    for (final candidate in candidates) {
      try {
        await _mutate(
          operationName: candidate.operationName,
          document: candidate.document,
          variables: variables,
        );
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (kDebugMode && lastError != null) {
      debugPrint('[Analytics] Failed to $debugName: $lastError');
    }
  }
}

class _MutationCandidate {
  final String operationName;
  final String document;

  const _MutationCandidate({
    required this.operationName,
    required this.document,
  });
}
