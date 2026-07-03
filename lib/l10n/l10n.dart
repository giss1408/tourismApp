// lib/l10n/l10n.dart
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart'; // ADD THIS IMPORT

class L10n {
  static Future<Map<String, String>> load(Locale locale) async {
    final String jsonContent = await rootBundle.loadString(
      'assets/locales/${locale.languageCode}.json',
    );
    final Map<String, dynamic> jsonMap = json.decode(jsonContent);
    return jsonMap.map((key, value) => MapEntry(key, value.toString()));
  }
}