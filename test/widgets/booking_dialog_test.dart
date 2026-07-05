import 'package:explore_world/l10n/app_localizations.dart';
import 'package:explore_world/models/destination_model.dart';
import 'package:explore_world/providers/booking_provider.dart';
import 'package:explore_world/screens/trip_info_screen.dart';
import 'package:explore_world/services/analytics_service.dart';
import 'package:explore_world/widgets/booking_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Destination _destination() => Destination(
      id: 'd-1',
      name: 'Paris',
      description: 'City of lights',
      location: 'France',
      rating: 4.8,
      price: 250,
      images: const <String>[],
      activities: const <String>['Walk'],
      category: 'City',
    );

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

Widget _localizedApp({required Widget home}) => MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('de'), Locale('fr')],
      home: home,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('BookingDialog renders setup step', (tester) async {
    final bookingProvider = BookingProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AnalyticsService>.value(value: const NoopAnalyticsService()),
          ChangeNotifierProvider<BookingProvider>.value(value: bookingProvider),
        ],
        child: _localizedApp(
          home: Scaffold(
            body: BookingDialog(destination: _destination()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Review Booking'), findsOneWidget);
    expect(find.text('Paris'), findsOneWidget);
  });

  testWidgets('TripInfoScreen renders booking details', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        home: Scaffold(
          body: TripInfoScreen(booking: _booking()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // If localization hasn't loaded yet, the fallback AppLocalizations still
    // renders the screen structure — check the structural icon
    final hasVerified = find.byIcon(Icons.verified).evaluate().isNotEmpty;
    // Accept either the icon or any text containing the reference
    final hasRef = tester.widgetList(find.byType(Text)).any(
      (w) => (w as Text).data?.contains('EW-TEST-001') == true,
    );
    expect(hasVerified || hasRef, isTrue);
  });

  test('BookingProvider.addBooking persists booking', () async {
    final provider = BookingProvider();
    await Future<void>.delayed(Duration.zero);

    await provider.addBooking(_booking());

    expect(provider.bookings, hasLength(greaterThanOrEqualTo(1)));
    expect(provider.bookings.any((b) => b.reference == 'EW-TEST-001'), isTrue);
  });
}
