abstract class AnalyticsService {
  Future<void> trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  });

  Future<void> setUserProperties(Map<String, Object?> properties);
}

class NoopAnalyticsService implements AnalyticsService {
  const NoopAnalyticsService();

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {}

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {}
}

class AnalyticsEvent {
  final String name;
  final Map<String, Object?> properties;
  final DateTime timestamp;

  const AnalyticsEvent({
    required this.name,
    required this.properties,
    required this.timestamp,
  });
}
