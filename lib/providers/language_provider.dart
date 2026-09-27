// providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  /// Until the traveller picks a language, follow the phone's when we
  /// support it; otherwise French, the language of Côte d'Ivoire.
  Locale _locale = _deviceLocale();

  static const fallbackLocale = Locale('fr');

  static Locale _deviceLocale() {
    final code =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported =
        supportedLanguages.any((language) => language['code'] == code);
    return supported ? Locale(code) : fallbackLocale;
  }

  Locale get locale => _locale;

  Future<void> loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final String? languageCode = prefs.getString('language');
    if (languageCode != null) {
      _locale = Locale(languageCode);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale newLocale) async {
    _locale = newLocale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);
    notifyListeners();
  }

  // Supported languages
  static final List<Map<String, String>> supportedLanguages = [
    {'code': 'fr', 'name': 'French', 'nativeName': 'Français'},
    {'code': 'en', 'name': 'English', 'nativeName': 'English'},
    {'code': 'de', 'name': 'German', 'nativeName': 'Deutsch'},
  ];

  String getCurrentLanguageName() {
    switch (_locale.languageCode) {
      case 'de':
        return 'Deutsch';
      case 'fr':
        return 'Français';
      default:
        return 'English';
    }
  }
}