import 'package:explore_world/models/destination_model.dart';
import 'package:explore_world/providers/personalization_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Destination _destination({
  required String id,
  required String category,
  required double price,
  double rating = 4.5,
}) {
  return Destination(
    id: id,
    name: 'Destination $id',
    description: 'Description',
    location: 'Location',
    rating: rating,
    price: price,
    images: const ['img'],
    activities: const ['activity'],
    category: category,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('tracks recently viewed destination ids', () async {
    final provider = PersonalizationProvider();

    await provider.trackView(_destination(id: '1', category: 'Beach', price: 200));
    await provider.trackView(_destination(id: '2', category: 'City', price: 300));

    expect(provider.recentlyViewedIds.first, '2');
    expect(provider.recentlyViewedIds, containsAll(['1', '2']));
  });

  test('recommendations exclude recently viewed destination ids', () async {
    final provider = PersonalizationProvider();

    final viewed = _destination(id: 'viewed', category: 'Beach', price: 220);
    final candidate = _destination(id: 'candidate', category: 'Beach', price: 230);

    await provider.trackView(viewed);

    final recommendations = provider.recommendations([viewed, candidate], limit: 5);

    expect(recommendations.any((destination) => destination.id == 'viewed'), isFalse);
    expect(recommendations.any((destination) => destination.id == 'candidate'), isTrue);
  });

  test('load handles malformed category interest cache safely', () async {
    SharedPreferences.setMockInitialValues({
      'personalization_category_interest': '{not-valid-json',
    });

    final provider = PersonalizationProvider();
    await Future<void>.delayed(Duration.zero);

    expect(provider.isLoaded, isTrue);
    expect(provider.recommendations(const <Destination>[]), isEmpty);
  });

  test('repeated immediate trackView for same destination avoids duplicate history writes', () async {
    final provider = PersonalizationProvider();
    final destination = _destination(id: 'same', category: 'Beach', price: 200);

    await provider.trackView(destination);
    final firstLength = provider.recentlyViewedIds.length;
    await provider.trackView(destination);

    expect(provider.recentlyViewedIds.length, firstLength);
    expect(provider.recentlyViewedIds.first, 'same');
  });

  test('recommendations honor limit and provide fallback when all viewed', () async {
    final provider = PersonalizationProvider();
    final all = [
      _destination(id: '1', category: 'Beach', price: 120),
      _destination(id: '2', category: 'City', price: 140),
      _destination(id: '3', category: 'Nature', price: 160),
    ];

    for (final destination in all) {
      await provider.trackView(destination);
    }

    final recommendations = provider.recommendations(all, limit: 2);
    expect(recommendations.length, 2);
  });
}
