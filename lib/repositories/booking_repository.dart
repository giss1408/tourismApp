import '../providers/booking_provider.dart';
import 'query_options.dart';

abstract class BookingRepository {
  Future<List<Booking>> fetchBookings({
    BookingQueryOptions? options,
  });
  Future<void> saveBookings(List<Booking> bookings);
}
