// providers/booking_provider.dart
import 'package:flutter/foundation.dart';

class Booking {
  final String id;
  final String destinationName;
  final String destinationImage;
  final String location;
  final DateTime bookingDate;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int guests;
  final int nights;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.destinationName,
    required this.destinationImage,
    required this.location,
    required this.bookingDate,
    required this.checkInDate,
    required this.checkOutDate,
    required this.guests,
    required this.nights,
    required this.totalPrice,
    required this.status,
  });
}

class BookingProvider with ChangeNotifier {
  final List<Booking> _bookings = [];

  List<Booking> get bookings => _bookings;

  void addBooking(Booking booking) {
    _bookings.add(booking);
    notifyListeners();
  }

  void cancelBooking(String bookingId) {
    _bookings.removeWhere((booking) => booking.id == bookingId);
    notifyListeners();
  }

  // Sample data for demo
  void loadSampleBookings() {
    _bookings.addAll([
      Booking(
        id: '1',
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
      ),
    ]);
    notifyListeners();
  }
}