import 'package:explore_world/services/mock_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('MockAnalyticsService stores event payload shape', () async {
    final analytics = MockAnalyticsService();

    await analytics.trackEvent(
      'destination_opened',
      properties: <String, Object?>{
        'destination_id': 'd1',
        'category': 'Beach',
        'price': 199.0,
      },
    );

    expect(analytics.events, hasLength(1));
    final event = analytics.events.single;
    expect(event.name, 'destination_opened');
    expect(event.properties['destination_id'], 'd1');
    expect(event.properties['category'], 'Beach');
    expect(event.properties['price'], 199.0);
    expect(event.timestamp, isA<DateTime>());
  });

  test('MockAnalyticsService stores user properties', () async {
    final analytics = MockAnalyticsService();

    await analytics.setUserProperties(<String, Object?>{
      'locale': 'en',
      'platform': 'android',
    });

    expect(analytics.userProperties['locale'], 'en');
    expect(analytics.userProperties['platform'], 'android');
  });
}
