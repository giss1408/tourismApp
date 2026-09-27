import '../models/travel_models.dart';
import '../services/graphql_service.dart';

/// Backend features beyond destinations and bookings: settings, reviews,
/// guides, payments, cancellation, devices and account management.
abstract class TravelRepository {
  Future<AppSettings> fetchAppSettings(String language);
  Future<List<Review>> fetchReviews(String destinationId);
  Future<Review> submitReview(String destinationId, int rating, String comment);
  Future<List<Guide>> fetchGuides(String destinationId);
  Future<PaymentSheetData> createBookingPayment(String reference);

  /// Cancels the booking; true when it was refunded.
  Future<bool> cancelBooking(String reference);
  Future<void> registerDevice(String token, String platform);
  Future<void> unregisterDevice(String token);
  Future<void> updateLanguage(String language);

  /// [password] is required for email/password accounts.
  Future<void> deleteAccount({String? password});
}

class ApiTravelRepository implements TravelRepository {
  final GraphQlService _graphQl;

  ApiTravelRepository({required String endpoint})
      : _graphQl = GraphQlService(endpoint: endpoint);

  Future<Map<String, dynamic>> _mutate(
    String name,
    String document,
    Map<String, dynamic> variables,
  ) async {
    final result = await _graphQl.mutate(
      operationName: name,
      document: document,
      variables: variables,
    );
    return result.data ?? const {};
  }

  @override
  Future<AppSettings> fetchAppSettings(String language) async {
    final result = await _graphQl.query(
      operationName: 'AppSettings',
      document: r'''
        query AppSettings($language: String) {
          appSettings(language: $language) {
            companyName supportEmail supportWhatsapp serviceFeeEur
            freeCancellationDays paymentsEnabled stripePublishableKey
            privacyPolicyUrl termsUrl
          }
        }
      ''',
      variables: {'language': language},
    );
    final json = result.data?['appSettings'] as Map<String, dynamic>?;
    return json == null ? const AppSettings() : AppSettings.fromJson(json);
  }

  @override
  Future<List<Review>> fetchReviews(String destinationId) async {
    final result = await _graphQl.query(
      operationName: 'Reviews',
      document: r'''
        query Reviews($destinationId: ID!) {
          reviews(destinationId: $destinationId, pageSize: 20) {
            id rating comment authorName createdAt isMine
          }
        }
      ''',
      variables: {'destinationId': destinationId},
    );
    return (result.data?['reviews'] as List<dynamic>? ?? const [])
        .map((item) => Review.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Review> submitReview(
      String destinationId, int rating, String comment) async {
    final data = await _mutate('SubmitReview', r'''
      mutation SubmitReview($destinationId: ID!, $rating: Int!, $comment: String) {
        submitReview(destinationId: $destinationId, rating: $rating, comment: $comment) {
          id rating comment authorName createdAt isMine
        }
      }
    ''', {'destinationId': destinationId, 'rating': rating, 'comment': comment});
    return Review.fromJson(data['submitReview'] as Map<String, dynamic>);
  }

  @override
  Future<List<Guide>> fetchGuides(String destinationId) async {
    final result = await _graphQl.query(
      operationName: 'Guides',
      document: r'''
        query Guides($destinationId: ID) {
          guides(destinationId: $destinationId) {
            id name bio languages photoUrl whatsapp
          }
        }
      ''',
      variables: {'destinationId': destinationId},
    );
    return (result.data?['guides'] as List<dynamic>? ?? const [])
        .map((item) => Guide.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<PaymentSheetData> createBookingPayment(String reference) async {
    final data = await _mutate('CreateBookingPayment', r'''
      mutation CreateBookingPayment($reference: String!) {
        createBookingPayment(reference: $reference) {
          clientSecret publishableKey merchantDisplayName
        }
      }
    ''', {'reference': reference});
    final json = data['createBookingPayment'] as Map<String, dynamic>;
    return PaymentSheetData(
      clientSecret: json['clientSecret'] as String,
      publishableKey: json['publishableKey'] as String,
      merchantDisplayName: json['merchantDisplayName'] as String? ?? 'Akwaba Ivoire',
    );
  }

  @override
  Future<bool> cancelBooking(String reference) async {
    final data = await _mutate('CancelBooking', r'''
      mutation CancelBooking($reference: String!) {
        cancelBooking(reference: $reference) { ok refunded }
      }
    ''', {'reference': reference});
    return (data['cancelBooking'] as Map<String, dynamic>?)?['refunded'] == true;
  }

  @override
  Future<void> registerDevice(String token, String platform) => _mutate(
        'RegisterDevice',
        r'''
          mutation RegisterDevice($token: String!, $platform: String) {
            registerDevice(token: $token, platform: $platform) { ok }
          }
        ''',
        {'token': token, 'platform': platform},
      );

  @override
  Future<void> unregisterDevice(String token) => _mutate(
        'UnregisterDevice',
        r'''
          mutation UnregisterDevice($token: String!) {
            unregisterDevice(token: $token) { ok }
          }
        ''',
        {'token': token},
      );

  @override
  Future<void> updateLanguage(String language) => _mutate(
        'UpdatePreferences',
        r'''
          mutation UpdatePreferences($language: String!) {
            updatePreferences(language: $language) { ok }
          }
        ''',
        {'language': language},
      );

  @override
  Future<void> deleteAccount({String? password}) => _mutate(
        'DeleteAccount',
        r'''
          mutation DeleteAccount($password: String) {
            deleteAccount(password: $password) { ok }
          }
        ''',
        {'password': password},
      );
}

/// Demo mode (no backend): read-only data, no payments or accounts.
class MockTravelRepository implements TravelRepository {
  const MockTravelRepository();

  @override
  Future<AppSettings> fetchAppSettings(String language) async =>
      const AppSettings();

  @override
  Future<List<Review>> fetchReviews(String destinationId) async => const [];

  @override
  Future<Review> submitReview(String destinationId, int rating, String comment) =>
      Future.error(UnsupportedError('Reviews need the online service.'));

  @override
  Future<List<Guide>> fetchGuides(String destinationId) async => const [];

  @override
  Future<PaymentSheetData> createBookingPayment(String reference) =>
      Future.error(UnsupportedError('Online payment is not available yet.'));

  @override
  Future<bool> cancelBooking(String reference) async => false;

  @override
  Future<void> registerDevice(String token, String platform) async {}

  @override
  Future<void> unregisterDevice(String token) async {}

  @override
  Future<void> updateLanguage(String language) async {}

  @override
  Future<void> deleteAccount({String? password}) async {}
}
