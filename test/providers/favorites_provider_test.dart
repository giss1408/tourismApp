import 'package:explore_world/providers/favorites_provider.dart';
import 'package:explore_world/services/mock_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('toggleFavorite emits favorite_added with destination payload', () async {
    final analytics = MockAnalyticsService();
    final provider = FavoritesProvider(analytics: analytics);

    await Future<void>.delayed(Duration.zero);
    await provider.toggleFavorite('dest-1');

    expect(provider.isFavorite('dest-1'), isTrue);
    expect(analytics.events, hasLength(1));
    expect(analytics.events.first.name, 'favorite_added');
    expect(analytics.events.first.properties['destination_id'], 'dest-1');
  });

  test('addToCollection emits collection save payload', () async {
    final analytics = MockAnalyticsService();
    final provider = FavoritesProvider(analytics: analytics);

    await Future<void>.delayed(Duration.zero);
    await provider.createCollection('Summer 2026');
    await provider.addToCollection('Summer 2026', 'dest-2');

    expect(analytics.events, hasLength(2));
    expect(analytics.events[0].name, 'collection_created');
    expect(analytics.events[0].properties['collection_name'], 'Summer 2026');

    final saveEvent = analytics.events[1];
    expect(saveEvent.name, 'destination_saved_to_collection');
    expect(saveEvent.properties['collection_name'], 'Summer 2026');
    expect(saveEvent.properties['destination_id'], 'dest-2');
  });

  test('load handles malformed collections cache without throwing', () async {
    SharedPreferences.setMockInitialValues({
      'favorite_collections': '{not-valid-json',
    });

    final analytics = MockAnalyticsService();
    final provider = FavoritesProvider(analytics: analytics);
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoaded, isTrue);
    expect(provider.collections, isEmpty);
  });

  test('toggleFavorite removes destination from collections when unfavorited', () async {
    final analytics = MockAnalyticsService();
    final provider = FavoritesProvider(analytics: analytics);

    await Future<void>.delayed(Duration.zero);
    await provider.createCollection('City Break');
    await provider.addToCollection('City Break', 'dest-42');
    await provider.toggleFavorite('dest-42');

    expect(provider.isFavorite('dest-42'), isFalse);
    expect(provider.collectionsForDestination('dest-42'), isEmpty);
    expect(analytics.events.last.name, 'favorite_removed');
  });

  test('createCollection ignores duplicate trimmed names', () async {
    final analytics = MockAnalyticsService();
    final provider = FavoritesProvider(analytics: analytics);

    await Future<void>.delayed(Duration.zero);
    await provider.createCollection('  Summer 2026  ');
    await provider.createCollection('Summer 2026');

    expect(provider.collectionNames.where((name) => name == 'Summer 2026'), hasLength(1));
    expect(
      analytics.events.where((event) => event.name == 'collection_created'),
      hasLength(1),
    );
  });
}
