/// Operator settings served by the backend (`appSettings`), with offline
/// defaults matching the backend's.
class AppSettings {
  final String companyName;
  final String supportEmail;

  /// International number without '+', or empty when not configured.
  final String supportWhatsapp;
  final double serviceFeeEur;
  final int freeCancellationDays;
  final bool paymentsEnabled;
  final String stripePublishableKey;
  final String privacyPolicyUrl;
  final String termsUrl;

  const AppSettings({
    this.companyName = 'Akwaba Ivoire',
    this.supportEmail = 'support@akwaba-ivoire.com',
    this.supportWhatsapp = '',
    this.serviceFeeEur = 29,
    this.freeCancellationDays = 7,
    this.paymentsEnabled = false,
    this.stripePublishableKey = '',
    this.privacyPolicyUrl = '',
    this.termsUrl = '',
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        companyName: json['companyName'] as String? ?? 'Akwaba Ivoire',
        supportEmail: json['supportEmail'] as String? ?? '',
        supportWhatsapp: json['supportWhatsapp'] as String? ?? '',
        serviceFeeEur: (json['serviceFeeEur'] as num?)?.toDouble() ?? 29,
        freeCancellationDays: (json['freeCancellationDays'] as num?)?.toInt() ?? 7,
        paymentsEnabled: json['paymentsEnabled'] as bool? ?? false,
        stripePublishableKey: json['stripePublishableKey'] as String? ?? '',
        privacyPolicyUrl: json['privacyPolicyUrl'] as String? ?? '',
        termsUrl: json['termsUrl'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'companyName': companyName,
        'supportEmail': supportEmail,
        'supportWhatsapp': supportWhatsapp,
        'serviceFeeEur': serviceFeeEur,
        'freeCancellationDays': freeCancellationDays,
        'paymentsEnabled': paymentsEnabled,
        'stripePublishableKey': stripePublishableKey,
        'privacyPolicyUrl': privacyPolicyUrl,
        'termsUrl': termsUrl,
      };
}

class Review {
  final String id;
  final int rating;
  final String comment;
  final String authorName;
  final DateTime? createdAt;
  final bool isMine;

  const Review({
    required this.id,
    required this.rating,
    required this.comment,
    required this.authorName,
    this.createdAt,
    this.isMine = false,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: '${json['id'] ?? ''}',
        rating: (json['rating'] as num?)?.toInt() ?? 0,
        comment: json['comment'] as String? ?? '',
        authorName: json['authorName'] as String? ?? '',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        isMine: json['isMine'] as bool? ?? false,
      );
}

class Guide {
  final String id;
  final String name;
  final String bio;
  final List<String> languages;
  final String photoUrl;

  /// International number without '+', or empty.
  final String whatsapp;

  const Guide({
    required this.id,
    required this.name,
    this.bio = '',
    this.languages = const [],
    this.photoUrl = '',
    this.whatsapp = '',
  });

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
        id: '${json['id'] ?? ''}',
        name: json['name'] as String? ?? '',
        bio: json['bio'] as String? ?? '',
        languages: (json['languages'] as List<dynamic>? ?? const [])
            .map((language) => '$language')
            .toList(),
        photoUrl: json['photoUrl'] as String? ?? '',
        whatsapp: json['whatsapp'] as String? ?? '',
      );
}

/// What the Stripe payment sheet needs, from `createBookingPayment`.
class PaymentSheetData {
  final String clientSecret;
  final String publishableKey;
  final String merchantDisplayName;

  const PaymentSheetData({
    required this.clientSecret,
    required this.publishableKey,
    required this.merchantDisplayName,
  });
}
