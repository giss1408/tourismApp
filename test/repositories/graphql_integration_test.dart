import 'package:explore_world/repositories/api_booking_repository.dart';
import 'package:explore_world/repositories/api_destination_repository.dart';
import 'package:explore_world/repositories/query_options.dart';
import 'package:flutter_test/flutter_test.dart';

const bool _runIntegration = bool.fromEnvironment(
  'RUN_GRAPHQL_INTEGRATION_TESTS',
  defaultValue: false,
);
const String _endpoint = String.fromEnvironment('GRAPHQL_ENDPOINT');
const String _authToken = String.fromEnvironment('GRAPHQL_AUTH_TOKEN');

void main() {
  group(
    'GraphQL integration (opt-in)',
    () {
      late ApiDestinationRepository destinationRepository;
      late ApiBookingRepository bookingRepository;

      setUp(() {
        if (_endpoint.isEmpty) {
          fail('GRAPHQL_ENDPOINT is required when RUN_GRAPHQL_INTEGRATION_TESTS=true');
        }

        destinationRepository = ApiDestinationRepository(
          endpoint: _endpoint,
          authToken: _authToken,
        );
        bookingRepository = ApiBookingRepository(
          endpoint: _endpoint,
          authToken: _authToken,
        );
      });

      test('destinations query succeeds with server-side options', () async {
        final items = await destinationRepository.fetchDestinations(
          options: const DestinationQueryOptions(page: 1, pageSize: 5),
        );

        expect(items, isA<List>());
      });

      test('bookings query succeeds with server-side options', () async {
        final items = await bookingRepository.fetchBookings(
          options: const BookingQueryOptions(page: 1, pageSize: 5),
        );

        expect(items, isA<List>());
      });
    },
    skip: !_runIntegration,
  );
}
