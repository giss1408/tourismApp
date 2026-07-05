import 'package:explore_world/repositories/dto/auth_user_dto.dart';
import 'package:explore_world/repositories/dto/booking_dto.dart';
import 'package:explore_world/repositories/dto/destination_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DestinationDto mapping', () {
    test('handles missing and null fields with safe defaults', () {
      final dto = DestinationDto.fromJson({
        'id': null,
        'rating': null,
        'price': null,
        'images': null,
        'activities': null,
      });

      final domain = dto.toDomain();
      expect(domain.id, '');
      expect(domain.rating, 0);
      expect(domain.price, 0);
      expect(domain.images, isEmpty);
      expect(domain.activities, isEmpty);
      expect(domain.category, 'General');
    });
  });

  group('BookingDto mapping', () {
    test('handles malformed date and numeric fields', () {
      final dto = BookingDto.fromJson({
        'id': 'b1',
        'reference': 'ref',
        'destinationId': 'd1',
        'destinationName': 'Name',
        'destinationImage': 'img',
        'location': 'Loc',
        'bookingDate': 'not-a-date',
        'checkInDate': null,
        'checkOutDate': '',
        'guests': null,
        'nights': null,
        'totalPrice': null,
        'status': null,
        'notes': null,
      });

      final domain = dto.toDomain();
      expect(domain.guests, 1);
      expect(domain.nights, 1);
      expect(domain.totalPrice, 0);
      expect(domain.status, 'Pending');
      expect(domain.notes, '');
      expect(domain.bookingDate.millisecondsSinceEpoch, 0);
      expect(domain.checkInDate.millisecondsSinceEpoch, 0);
      expect(domain.checkOutDate.millisecondsSinceEpoch, 0);
    });

    test('serializes domain object to GraphQL input payload', () {
      final dto = BookingDto.fromJson({
        'id': 'b2',
        'reference': 'EW-1',
        'destinationId': 'd2',
        'destinationName': 'Name',
        'destinationImage': 'img',
        'location': 'Loc',
        'bookingDate': '2026-01-01T10:00:00.000Z',
        'checkInDate': '2026-02-01T10:00:00.000Z',
        'checkOutDate': '2026-02-03T10:00:00.000Z',
        'guests': 2,
        'nights': 2,
        'totalPrice': 500,
        'status': 'Confirmed',
        'notes': 'Window seat',
      });

      final payload = BookingDto.fromDomain(dto.toDomain()).toInputJson();
      expect(payload['id'], 'b2');
      expect(payload['guests'], 2);
      expect(payload['bookingDate'], isA<String>());
      expect(payload['checkInDate'], isA<String>());
      expect(payload['checkOutDate'], isA<String>());
    });
  });

  group('AuthUserDto mapping', () {
    test('handles missing optional fields and malformed createdAt', () {
      final dto = AuthUserDto.fromJson({
        'uid': null,
        'createdAt': 'not-a-date',
      });

      final user = dto.toDomain();
      expect(user.uid, '');
      expect(user.email, isNull);
      expect(user.displayName, isNull);
      expect(user.createdAt, isNull);
    });
  });
}
