import 'package:explore_world/models/travel_models.dart';
import 'package:explore_world/providers/consent_provider.dart';
import 'package:explore_world/services/mock_analytics_service.dart';
import 'package:explore_world/utils/money.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _format(WidgetTester tester, Locale locale,
    String Function(BuildContext) format) async {
  late String result;
  await tester.pumpWidget(Localizations(
    locale: locale,
    delegates: const [DefaultWidgetsLocalizations.delegate],
    child: Builder(builder: (context) {
      result = format(context);
      return const SizedBox();
    }),
  ));
  return result;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('usage statistics are only sent after consent', () async {
    final consent = ConsentProvider();
    await consent.load();
    final inner = MockAnalyticsService();
    final analytics = ConsentAnalyticsService(inner, consent);

    expect(consent.needsAnswer, isTrue);
    await analytics.trackEvent('before_consent');
    await consent.setAnalyticsAllowed(true);
    await analytics.trackEvent('after_consent');
    await consent.setAnalyticsAllowed(false);
    await analytics.trackEvent('after_withdrawal');

    expect(inner.events.map((event) => event.name), ['after_consent']);
  });

  test('app settings parse the backend values', () {
    final settings = AppSettings.fromJson(const {
      'supportWhatsapp': '2250700000000',
      'serviceFeeEur': 25,
      'freeCancellationDays': 10,
      'paymentsEnabled': true,
    });
    expect(settings.supportWhatsapp, '2250700000000');
    expect(settings.serviceFeeEur, 25.0);
    expect(settings.freeCancellationDays, 10);
    expect(settings.paymentsEnabled, isTrue);
    expect(AppSettings.fromJson(settings.toJson()).serviceFeeEur, 25.0);
  });

  testWidgets('prices follow the language, with the fixed CFA rate',
      (tester) async {
    expect(await _format(tester, const Locale('en'), (c) => Money.eur(c, 249)), '€249');
    expect(await _format(tester, const Locale('fr'), (c) => Money.eur(c, 249)),
        contains('249'));
    expect(await _format(tester, const Locale('en'), (c) => Money.xof(c, 100)),
        '65,596 FCFA');
  });
}
