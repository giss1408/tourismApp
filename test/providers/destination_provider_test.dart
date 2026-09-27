import 'package:explore_world/models/destination_model.dart';
import 'package:explore_world/providers/destination_provider.dart';
import 'package:explore_world/repositories/destination_repository.dart';
import 'package:explore_world/repositories/query_options.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDestinationRepository implements DestinationRepository {
  final List<Destination> destinations;

  _FakeDestinationRepository({required this.destinations});

  @override
  Future<List<Destination>> fetchDestinations({
    DestinationQueryOptions? options,
  }) async => destinations;
}

class _ThrowingDestinationRepository implements DestinationRepository {
  @override
  Future<List<Destination>> fetchDestinations({
    DestinationQueryOptions? options,
  }) async {
    throw Exception('Repository failure');
  }
}

void main() {
  test('DestinationProvider loads data through repository contract', () async {
    final provider = DestinationProvider(
      repository: _FakeDestinationRepository(
        destinations: [
          Destination(
            id: 'id_1',
            name: 'Test Destination',
            description: 'Description',
            location: 'Paris, France',
            rating: 4.5,
            price: 100,
            images: ['img'],
            activities: ['walk'],
            category: 'City',
            isFeatured: true,
            latitude: 48.8566,
            longitude: 2.3522,
          ),
        ],
      ),
    );

    await provider.loadDestinations();

    expect(provider.status, DestinationDataStatus.success);
    expect(provider.error, isEmpty);
    expect(provider.destinations, hasLength(1));
    expect(provider.featuredDestinations, hasLength(1));
  });

  test('DestinationProvider sets error state on repository failure', () async {
    final provider = DestinationProvider(
      repository: _ThrowingDestinationRepository(),
    );

    await provider.loadDestinations();

    expect(provider.status, DestinationDataStatus.error);
    expect(provider.destinations, isEmpty);
    expect(provider.error, contains('Unable to load destinations'));
  });

  test('DestinationProvider shows the cached catalogue when offline', () async {
    SharedPreferences.setMockInitialValues({});
    final online = DestinationProvider(
      repository: _FakeDestinationRepository(destinations: [
        Destination(
          id: '7',
          name: 'Grand-Bassam',
          description: 'Plage classée UNESCO',
          location: "Côte d'Ivoire",
          rating: 4.8,
          price: 90,
          images: const ['img'],
          activities: const ['plage'],
          category: 'Beach',
        ),
      ]),
    );
    await online.loadDestinations();

    final offline = DestinationProvider(repository: _ThrowingDestinationRepository());
    await offline.loadDestinations();

    expect(offline.status, DestinationDataStatus.success);
    expect(offline.isOffline, isTrue);
    expect(offline.destinations.single.name, 'Grand-Bassam');
  });
}
