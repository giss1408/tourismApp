import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/travel_models.dart';
import '../repositories/travel_repository.dart';

/// Operator settings (fees, cancellation window, contacts, legal links),
/// cached so they are available offline.
class AppSettingsProvider with ChangeNotifier {
  final TravelRepository _repository;
  static const _cacheKey = 'app_settings_cache_v1';

  AppSettings _settings = const AppSettings();
  AppSettings get settings => _settings;

  AppSettingsProvider({required TravelRepository repository})
      : _repository = repository;

  Future<void> load(String language) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        _settings = AppSettings.fromJson(jsonDecode(cached) as Map<String, dynamic>);
        notifyListeners();
      } catch (_) {}
    }
    try {
      _settings = await _repository.fetchAppSettings(language);
      await prefs.setString(_cacheKey, jsonEncode(_settings.toJson()));
      notifyListeners();
    } catch (e) {
      if (kDebugMode) debugPrint('[AppSettings] using cached/default settings: $e');
    }
  }
}
