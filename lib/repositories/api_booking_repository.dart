import 'dto/booking_dto.dart';
import '../providers/booking_provider.dart';
import 'query_options.dart';
import '../services/graphql_service.dart';
import 'booking_repository.dart';

class ApiBookingRepository implements BookingRepository {
  final GraphQlService _graphQl;

  ApiBookingRepository({
    required String endpoint,
    String? authToken,
  }) : _graphQl = GraphQlService(endpoint: endpoint, authToken: authToken);

  @override
  Future<List<Booking>> fetchBookings({
    BookingQueryOptions? options,
  }) async {
    const query = r'''
      query GetBookings(
        $userId: String
        $status: String
        $sortBy: String
        $sortDirection: String
        $page: Int
        $pageSize: Int
      ) {
        bookings(
          userId: $userId
          status: $status
          sortBy: $sortBy
          sortDirection: $sortDirection
          page: $page
          pageSize: $pageSize
        ) {
          id
          reference
          destinationId
          destinationName
          destinationImage
          location
          bookingDate
          checkInDate
          checkOutDate
          guests
          nights
          totalPrice
          status
          notes
        }
      }
    ''';

    final result = await _graphQl.query(
      operationName: 'GetBookings',
      document: query,
      variables: options?.toVariables() ?? const {},
    );

    final rawList = result.data?['bookings'] as List<dynamic>?;
    if (rawList == null) {
      return [];
    }

    return rawList
        .whereType<Map<String, dynamic>>()
      .map(BookingDto.fromJson)
      .map((dto) => dto.toDomain())
        .toList(growable: false);
  }

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    const mutation = r'''
      mutation UpsertBookings($bookings: [BookingInputType!]!) {
        upsertBookings(bookings: $bookings)
      }
    ''';

    final variables = {
      'bookings': bookings
          .map(BookingDto.fromDomain)
          .map((dto) => dto.toInputJson())
          .toList(growable: false),
    };

    await _graphQl.mutate(
      operationName: 'UpsertBookings',
      document: mutation,
      variables: variables,
    );
  }
}
