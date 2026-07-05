import '../l10n/app_localizations.dart';
import '../models/destination_model.dart';

class DestinationInfoRequestData {
  final String questionType;
  final String preferredContact;

  const DestinationInfoRequestData({
    required this.questionType,
    required this.preferredContact,
  });
}

class DestinationInfoRequestService {
  static List<String> localizedQuestionTypes(AppLocalizations localizations) {
    return <String>[
      localizations.availabilityAndDates,
      localizations.pricingAndDiscounts,
      localizations.includedServices,
      localizations.transportationDetails,
      localizations.cancellationPolicy,
      localizations.other,
    ];
  }

  static String buildSubject(
    AppLocalizations localizations,
    Destination destination,
  ) {
    return '${localizations.infoEmailSubjectPrefix} ${destination.name}';
  }

  static String buildBody(
    AppLocalizations localizations,
    Destination destination,
    DestinationInfoRequestData data,
  ) {
    return <String>[
      localizations.infoEmailGreeting,
      '',
      localizations.infoEmailIntro,
      '- ${localizations.infoEmailNameLabel}: ${destination.name}',
      '- ${localizations.infoEmailLocationLabel}: ${destination.location}',
      '- ${localizations.infoEmailPriceLabel}: \$${destination.discountedPrice.toStringAsFixed(2)}',
      '- ${localizations.infoEmailQuestionTypeLabel}: ${data.questionType}',
      '- ${localizations.infoEmailPreferredContactLabel}: ${data.preferredContact}',
      '',
      localizations.infoEmailClosingRequest,
      '',
      localizations.infoEmailThanks,
    ].join('\n');
  }

  static Map<String, Object?> analyticsPayload(
    Destination destination,
    DestinationInfoRequestData data,
  ) {
    return <String, Object?>{
      'destination_id': destination.id,
      'destination_name': destination.name,
      'location': destination.location,
      'question_type': data.questionType,
      'preferred_contact': data.preferredContact,
    };
  }
}
