import 'package:explore_world/l10n/app_localizations.dart';
import 'package:explore_world/providers/booking_provider.dart';
import 'package:explore_world/screens/trip_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Booking _booking() => Booking(
      id: 'b1',
      reference: 'EW-TEST-001',
      destinationId: 'd-1',
      destinationName: 'Paris',
      destinationImage: '',
      location: 'France',
      bookingDate: DateTime(2026, 9, 1),
      checkInDate: DateTime(2026, 9, 10),
      checkOutDate: DateTime(2026, 9, 15),
      guests: 2,
      nights: 5,
      totalPrice: 1279.0,
      status: 'Confirmed',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('TripInfoScreen renders booking confirmation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en'), Locale('de'), Locale('fr')],
        home: Scaffold(body: TripInfoScreen(booking: _booking())),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.verified), findsOneWidget);
    expect(
      tester.widgetList(find.byType(Text)).any(
        (w) => (w as Text).data?.contains('EW-TEST-001') == true,
      ),
      isTrue,
    );
  });
}
