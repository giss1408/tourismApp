import '../../providers/booking_provider.dart';

class BookingDto {
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

  const BookingDto({
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
    required this.notes,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: (json['id'] ?? '').toString(),
      reference: (json['reference'] ?? '').toString(),
      destinationId: (json['destinationId'] ?? '').toString(),
      destinationName: (json['destinationName'] ?? '').toString(),
      destinationImage: (json['destinationImage'] ?? '').toString(),
      location: (json['location'] ?? '').toString(),
      bookingDate: DateTime.tryParse((json['bookingDate'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      checkInDate: DateTime.tryParse((json['checkInDate'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      checkOutDate: DateTime.tryParse((json['checkOutDate'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      guests: (json['guests'] as num?)?.toInt() ?? 1,
      nights: (json['nights'] as num?)?.toInt() ?? 1,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0,
      status: (json['status'] ?? 'Pending').toString(),
      notes: (json['notes'] ?? '').toString(),
    );
  }

  factory BookingDto.fromDomain(Booking booking) {
    return BookingDto(
      id: booking.id,
      reference: booking.reference,
      destinationId: booking.destinationId,
      destinationName: booking.destinationName,
      destinationImage: booking.destinationImage,
      location: booking.location,
      bookingDate: booking.bookingDate,
      checkInDate: booking.checkInDate,
      checkOutDate: booking.checkOutDate,
      guests: booking.guests,
      nights: booking.nights,
      totalPrice: booking.totalPrice,
      status: booking.status,
      notes: booking.notes,
    );
  }

  Booking toDomain() {
    return Booking(
      id: id,
      reference: reference,
      destinationId: destinationId,
      destinationName: destinationName,
      destinationImage: destinationImage,
      location: location,
      bookingDate: bookingDate,
      checkInDate: checkInDate,
      checkOutDate: checkOutDate,
      guests: guests,
      nights: nights,
      totalPrice: totalPrice,
      status: status,
      notes: notes,
    );
  }

  Map<String, dynamic> toInputJson() {
    return {
      'id': id,
      'reference': reference,
      'destinationId': destinationId,
      'destinationName': destinationName,
      'destinationImage': destinationImage,
      'location': location,
      'bookingDate': bookingDate.toIso8601String(),
      'checkInDate': checkInDate.toIso8601String(),
      'checkOutDate': checkOutDate.toIso8601String(),
      'guests': guests,
      'nights': nights,
      'totalPrice': totalPrice,
      'status': status,
      'notes': notes,
    };
  }
}
