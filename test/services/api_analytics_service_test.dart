import 'package:explore_world/services/api_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('trackEvent sends payload to backend mutation', () async {
    String? capturedOperationName;
    String? capturedDocument;
    Map<String, dynamic>? capturedVariables;

    final service = ApiAnalyticsService(
      endpoint: 'https://example.com/graphql',
      mutate: ({
        required String operationName,
        required String document,
        Map<String, dynamic> variables = const {},
      }) async {
        capturedOperationName = operationName;
        capturedDocument = document;
        capturedVariables = variables;
      },
    );

    await service.trackEvent(
      'destination_opened',
      properties: <String, Object?>{
        'destination_id': 'd-1',
        'category': 'Beach',
      },
    );

    expect(capturedOperationName, 'TrackAnalyticsEvent');
    expect(capturedDocument, contains('trackAnalyticsEvent'));
    expect(capturedVariables, isNotNull);
    expect(capturedVariables!['input']['name'], 'destination_opened');
    expect(capturedVariables!['input']['properties']['destination_id'], 'd-1');
    expect(capturedVariables!['input']['properties']['category'], 'Beach');
    expect(capturedVariables!['input']['timestamp'], isA<String>());
  });

  test('setUserProperties sends properties payload', () async {
    String? capturedOperationName;
    Map<String, dynamic>? capturedVariables;

    final service = ApiAnalyticsService(
      endpoint: 'https://example.com/graphql',
      mutate: ({
        required String operationName,
        required String document,
        Map<String, dynamic> variables = const {},
      }) async {
        capturedOperationName = operationName;
        capturedVariables = variables;
      },
    );

    await service.setUserProperties(<String, Object?>{
      'locale': 'en',
      'platform': 'android',
    });

    expect(capturedOperationName, 'SetAnalyticsUserProperties');
    expect(capturedVariables, isNotNull);
    expect(capturedVariables!['properties']['locale'], 'en');
    expect(capturedVariables!['properties']['platform'], 'android');
  });

  test('uses fallback mutation when first candidate fails', () async {
    final calledOperations = <String>[];

    final service = ApiAnalyticsService(
      endpoint: 'https://example.com/graphql',
      mutate: ({
        required String operationName,
        required String document,
        Map<String, dynamic> variables = const {},
      }) async {
        calledOperations.add(operationName);
        if (operationName == 'TrackAnalyticsEvent') {
          throw Exception('Primary mutation not available');
        }
      },
    );

    await service.trackEvent('booking_started');

    expect(calledOperations, <String>['TrackAnalyticsEvent', 'LogAnalyticsEvent']);
  });
}
