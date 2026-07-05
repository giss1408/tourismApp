import '../providers/booking_provider.dart';
import 'booking_repository.dart';
import 'query_options.dart';

class MockBookingRepository implements BookingRepository {
  final List<Booking> _store = [
    Booking(
      id: '1',
      reference: 'EW-20260703-0001',
      destinationId: '1',
      destinationName: 'Bali Paradise',
      destinationImage: 'https://picsum.photos/400/300?random=1',
      location: 'Bali, Indonesia',
      bookingDate: DateTime(2024, 1, 15),
      checkInDate: DateTime(2024, 2, 1),
      checkOutDate: DateTime(2024, 2, 8),
      guests: 2,
      nights: 7,
      totalPrice: 2099.93,
      status: 'Confirmed',
      notes: 'Airport pickup included',
    ),
  ];

  @override
  Future<List<Booking>> fetchBookings({BookingQueryOptions? options}) async {
    Iterable<Booking> list = _store;

    if (options?.status != null && options!.status!.trim().isNotEmpty) {
      final status = options.status!.toLowerCase();
      list = list.where((b) => b.status.toLowerCase() == status);
    }

    final sorted = list.toList(growable: false);
    if (options?.sortBy == 'checkInDate') {
      sorted.sort((a, b) => a.checkInDate.compareTo(b.checkInDate));
      if (options?.sortDirection?.toLowerCase() == 'desc') {
        sorted.sort((a, b) => b.checkInDate.compareTo(a.checkInDate));
      }
    }

    if (options?.page != null && options?.pageSize != null) {
      final start = (options!.page! - 1) * options.pageSize!;
      if (start >= sorted.length || start < 0) {
        return const [];
      }
      final end = (start + options.pageSize!).clamp(0, sorted.length);
      return sorted.sublist(start, end);
    }

    return List<Booking>.from(sorted);
  }

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    _store
      ..clear()
      ..addAll(bookings);
  }
}
