import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/analytics_service.dart';

/// GDPR consent for usage statistics. Nothing is tracked until the traveller
/// accepts; the choice can be changed at any time in the profile.
class ConsentProvider with ChangeNotifier {
  static const _key = 'analytics_consent_v1';

  /// null until the traveller has answered.
  bool? _analyticsAllowed;
  bool _loaded = false;

  bool? get analyticsAllowed => _analyticsAllowed;
  bool get needsAnswer => _loaded && _analyticsAllowed == null;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _analyticsAllowed = prefs.getBool(_key);
    _loaded = true;
    notifyListeners();
  }

  Future<void> setAnalyticsAllowed(bool allowed) async {
    _analyticsAllowed = allowed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, allowed);
    notifyListeners();
  }
}

/// Forwards analytics only while the traveller consents.
class ConsentAnalyticsService implements AnalyticsService {
  final AnalyticsService _inner;
  final ConsentProvider _consent;

  ConsentAnalyticsService(this._inner, this._consent);

  bool get _allowed => _consent.analyticsAllowed == true;

  @override
  Future<void> trackEvent(String name,
      {Map<String, Object?> properties = const {}}) async {
    if (_allowed) await _inner.trackEvent(name, properties: properties);
  }

  @override
  Future<void> setUserProperties(Map<String, Object?> properties) async {
    if (_allowed) await _inner.setUserProperties(properties);
  }
}
