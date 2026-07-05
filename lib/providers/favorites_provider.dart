import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/analytics_service.dart';

class FavoritesProvider with ChangeNotifier {
  static const _favoritesKey = 'favorite_destination_ids';
  static const _collectionsKey = 'favorite_collections';

  final Set<String> _favoriteDestinationIds = <String>{};
  final Map<String, Set<String>> _collections = <String, Set<String>>{};
  final AnalyticsService _analytics;

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  Set<String> get favoriteDestinationIds => _favoriteDestinationIds;
  Map<String, Set<String>> get collections => _collections;

  FavoritesProvider({AnalyticsService? analytics})
      : _analytics = analytics ?? const NoopAnalyticsService() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    final favoriteIds = prefs.getStringList(_favoritesKey) ?? <String>[];
    _favoriteDestinationIds
      ..clear()
      ..addAll(favoriteIds);

    final collectionsRaw = prefs.getString(_collectionsKey);
    if (collectionsRaw != null && collectionsRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(collectionsRaw);
        if (decoded is! Map) {
          throw const FormatException('Favorites collections cache is not a map.');
        }

        _collections
          ..clear()
          ..addEntries(
            decoded.entries
                .where((entry) => entry.key is String)
                .map(
                  (entry) => MapEntry(
                    entry.key as String,
                    Set<String>.from((entry.value as List<dynamic>).map((item) => item.toString())),
                  ),
                ),
          );
      } catch (_) {
        _collections.clear();
        await prefs.remove(_collectionsKey);
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(_favoritesKey, _favoriteDestinationIds.toList());

    final collectionsJson = jsonEncode(
      _collections.map(
        (key, value) => MapEntry(key, value.toList()),
      ),
    );
    await prefs.setString(_collectionsKey, collectionsJson);
  }

  bool isFavorite(String destinationId) {
    return _favoriteDestinationIds.contains(destinationId);
  }

  Future<void> toggleFavorite(String destinationId) async {
    final wasFavorite = _favoriteDestinationIds.contains(destinationId);
    if (_favoriteDestinationIds.contains(destinationId)) {
      _favoriteDestinationIds.remove(destinationId);
      for (final collection in _collections.values) {
        collection.remove(destinationId);
      }
    } else {
      _favoriteDestinationIds.add(destinationId);
    }

    await _save();
    await _analytics.trackEvent(
      wasFavorite ? 'favorite_removed' : 'favorite_added',
      properties: <String, Object?>{
        'destination_id': destinationId,
      },
    );
    notifyListeners();
  }

  bool hasCollection(String collectionName) {
    return _collections.containsKey(collectionName.trim());
  }

  Future<void> createCollection(String collectionName) async {
    final name = collectionName.trim();
    if (name.isEmpty || _collections.containsKey(name)) {
      return;
    }

    _collections[name] = <String>{};
    await _save();
    await _analytics.trackEvent(
      'collection_created',
      properties: <String, Object?>{'collection_name': name},
    );
    notifyListeners();
  }

  Future<void> deleteCollection(String collectionName) async {
    _collections.remove(collectionName);
    await _save();
    notifyListeners();
  }

  Future<void> addToCollection(String collectionName, String destinationId) async {
    _collections.putIfAbsent(collectionName, () => <String>{});
    _collections[collectionName]!.add(destinationId);
    _favoriteDestinationIds.add(destinationId);

    await _save();
    await _analytics.trackEvent(
      'destination_saved_to_collection',
      properties: <String, Object?>{
        'collection_name': collectionName,
        'destination_id': destinationId,
      },
    );
    notifyListeners();
  }

  Future<void> removeFromCollection(String collectionName, String destinationId) async {
    final collection = _collections[collectionName];
    if (collection == null) {
      return;
    }

    collection.remove(destinationId);
    await _save();
    notifyListeners();
  }

  List<String> collectionsForDestination(String destinationId) {
    return _collections.entries
        .where((entry) => entry.value.contains(destinationId))
        .map((entry) => entry.key)
        .toList(growable: false);
  }

  List<String> get collectionNames {
    final names = _collections.keys.toList(growable: false);
    names.sort();
    return names;
  }
}
