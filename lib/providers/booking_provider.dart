// providers/booking_provider.dart
import 'package:flutter/foundation.dart';

import '../repositories/booking_repository.dart';
import '../repositories/mock_booking_repository.dart';
import '../repositories/query_options.dart';
import '../services/analytics_service.dart';

enum BookingDataStatus { idle, loading, success, error }

class Booking {
  final String id;
  final String reference;
  final String destinationId;
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
  final String notes;

  Booking({
    required this.id,
    required this.reference,
    required this.destinationId,
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
    this.notes = '',
  });

  Booking copyWith({
    DateTime? checkInDate,
    DateTime? checkOutDate,
    int? guests,
    int? nights,
    double? totalPrice,
    String? status,
    String? notes,
  }) {
    return Booking(
      id: id,
      reference: reference,
      destinationId: destinationId,
      destinationName: destinationName,
      destinationImage: destinationImage,
      location: location,
      bookingDate: bookingDate,
      checkInDate: checkInDate ?? this.checkInDate,
      checkOutDate: checkOutDate ?? this.checkOutDate,
      guests: guests ?? this.guests,
      nights: nights ?? this.nights,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }
}

class BookingProvider with ChangeNotifier {
  final BookingRepository _repository;
  final AnalyticsService _analytics;
  final List<Booking> _bookings = [];
  BookingDataStatus _status = BookingDataStatus.idle;
  String _error = '';

  BookingProvider({BookingRepository? repository, AnalyticsService? analytics})
      : _repository = repository ?? MockBookingRepository(),
        _analytics = analytics ?? const NoopAnalyticsService() {
    loadBookings();
  }

  List<Booking> get bookings => _bookings;
  BookingDataStatus get status => _status;
  String get error => _error;

  Future<void> loadBookings({BookingQueryOptions? options}) async {
    _status = BookingDataStatus.loading;
    _error = '';
    notifyListeners();

    try {
      final loaded = await _repository.fetchBookings(options: options);
      _bookings
        ..clear()
        ..addAll(loaded);
      _status = BookingDataStatus.success;
    } catch (e) {
      _bookings.clear();
      _status = BookingDataStatus.error;
      _error = 'Failed to load bookings: $e';
    }

    notifyListeners();
  }

  Future<void> addBooking(Booking booking) async {
    _bookings.add(booking);
    await _persistBookings();
    await _analytics.trackEvent(
      'booking_confirmed',
      properties: <String, Object?>{
        'booking_id': booking.id,
        'destination_id': booking.destinationId,
        'guests': booking.guests,
        'nights': booking.nights,
        'total_price': booking.totalPrice,
      },
    );
    notifyListeners();
  }

  Future<void> cancelBooking(String bookingId) async {
    await _updateBookingStatus(bookingId, 'Cancelled');
  }

  Future<void> confirmBooking(String bookingId) async {
    await _updateBookingStatus(bookingId, 'Confirmed');
  }

  Future<void> markPending(String bookingId) async {
    await _updateBookingStatus(bookingId, 'Pending');
  }

  Future<void> modifyBooking({
    required String bookingId,
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required int guests,
    required int nights,
    required double totalPrice,
    String? notes,
  }) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    _bookings[index] = _bookings[index].copyWith(
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guests: guests,
      nights: nights,
      totalPrice: totalPrice,
      notes: notes,
      status: 'Confirmed',
    );
    await _persistBookings();
    notifyListeners();
  }

  Booking? findById(String bookingId) {
    try {
      return _bookings.firstWhere((booking) => booking.id == bookingId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String status) async {
    final index = _bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1) {
      return;
    }

    final booking = _bookings[index];
    _bookings[index] = _bookings[index].copyWith(status: status);
    await _persistBookings();
    if (status == 'Cancelled') {
      await _analytics.trackEvent(
        'booking_canceled',
        properties: <String, Object?>{
          'booking_id': booking.id,
          'destination_id': booking.destinationId,
          'total_price': booking.totalPrice,
        },
      );
    }
    notifyListeners();
  }

  Future<void> _persistBookings() async {
    try {
      await _repository.saveBookings(_bookings);
      _error = '';
      if (_status == BookingDataStatus.idle || _status == BookingDataStatus.error) {
        _status = BookingDataStatus.success;
      }
    } catch (e) {
      _status = BookingDataStatus.error;
      _error = 'Failed to save bookings: $e';
    }
  }

  String generateReference() {
    final now = DateTime.now();
    final stamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final randomPart = now.millisecondsSinceEpoch.toString().substring(8);
    return 'EW-$stamp-$randomPart';
  }

  // Sample data for demo
  Future<void> loadSampleBookings() async {
    await loadBookings();
  }
}