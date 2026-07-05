import 'analytics_service.dart';

class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> _events = <AnalyticsEvent>[];
  final Map<String, Object?> _userProperties = <String, Object?>{};

  List<AnalyticsEvent> get events => List<AnalyticsEvent>.unmodifiable(_events);
  Map<String, Object?> get userProperties =>
      Map<String, Object?>.unmodifiable(_userProperties);

  @override
  Future<void> trackEvent(
    String name, {
    Map<String, Object?> properties = const {},
  }) async {
    _events.add(
      AnalyticsEvent(
        name: name,
        properties: Map<String, Object?>.from(properties),
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {
    _userProperties.addAll(properties);
  }

  void clear() {
    _events.clear();
    _userProperties.clear();
  }
}
