import 'package:explore_world/providers/booking_provider.dart';
import 'package:explore_world/repositories/booking_repository.dart';
import 'package:explore_world/repositories/query_options.dart';
import 'package:explore_world/services/mock_analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeBookingRepository implements BookingRepository {
  final List<Booking> _store;

  _FakeBookingRepository({required List<Booking> seedBookings})
      : _store = List<Booking>.from(seedBookings);

  @override
  Future<List<Booking>> fetchBookings({BookingQueryOptions? options}) async {
    return List<Booking>.from(_store);
  }

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    _store
      ..clear()
      ..addAll(bookings);
  }
}

class _ThrowingBookingRepository implements BookingRepository {
  @override
  Future<List<Booking>> fetchBookings({BookingQueryOptions? options}) async {
    throw Exception('Load failed');
  }

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    throw Exception('Save failed');
  }
}

Booking _sampleBooking() {
  return Booking(
    id: 'b1',
    reference: 'EW-20260703-0001',
    destinationId: 'd1',
    destinationName: 'Paris City Lights',
    destinationImage: 'https://picsum.photos/400/300?random=9',
    location: 'Paris, France',
    bookingDate: DateTime(2026, 7, 3),
    checkInDate: DateTime(2026, 8, 3),
    checkOutDate: DateTime(2026, 8, 7),
    guests: 2,
    nights: 4,
    totalPrice: 899,
    status: 'Confirmed',
  );
}

void main() {
  test('BookingProvider loads bookings through repository', () async {
    final provider = BookingProvider(
      repository: _FakeBookingRepository(seedBookings: [_sampleBooking()]),
    );

    await provider.loadBookings();

    expect(provider.status, BookingDataStatus.success);
    expect(provider.error, isEmpty);
    expect(provider.bookings, hasLength(1));
  });

  test('BookingProvider updates status and persists cancellation', () async {
    final analytics = MockAnalyticsService();
    final provider = BookingProvider(
      repository: _FakeBookingRepository(seedBookings: [_sampleBooking()]),
      analytics: analytics,
    );

    await provider.loadBookings();
    await provider.cancelBooking('b1');

    expect(provider.bookings.first.status, 'Cancelled');
    expect(provider.status, BookingDataStatus.success);
    expect(analytics.events, hasLength(1));
    expect(analytics.events.first.name, 'booking_canceled');
    expect(analytics.events.first.properties['booking_id'], 'b1');
    expect(analytics.events.first.properties['destination_id'], 'd1');
  });

  test('BookingProvider emits booking_confirmed with required payload', () async {
    final analytics = MockAnalyticsService();
    final provider = BookingProvider(
      repository: _FakeBookingRepository(seedBookings: <Booking>[]),
      analytics: analytics,
    );

    final booking = _sampleBooking();
    await provider.addBooking(booking);

    expect(analytics.events, hasLength(1));
    final event = analytics.events.first;
    expect(event.name, 'booking_confirmed');
    expect(event.properties['booking_id'], booking.id);
    expect(event.properties['destination_id'], booking.destinationId);
    expect(event.properties['guests'], booking.guests);
    expect(event.properties['nights'], booking.nights);
    expect(event.properties['total_price'], booking.totalPrice);
  });

  test('BookingProvider exposes error on repository load failure', () async {
    final provider = BookingProvider(
      repository: _ThrowingBookingRepository(),
    );

    await provider.loadBookings();

    expect(provider.status, BookingDataStatus.error);
    expect(provider.error, contains('Failed to load bookings'));
    expect(provider.bookings, isEmpty);
  });
}
