import 'package:explore_world/l10n/app_localizations.dart';
import 'package:explore_world/models/destination_model.dart';
import 'package:explore_world/providers/destination_provider.dart';
import 'package:explore_world/providers/favorites_provider.dart';
import 'package:explore_world/providers/personalization_provider.dart';
import 'package:explore_world/repositories/destination_repository.dart';
import 'package:explore_world/repositories/query_options.dart';
import 'package:explore_world/screens/destination_detail_screen.dart';
import 'package:explore_world/services/analytics_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeDestinationRepository implements DestinationRepository {
  final List<Destination> _items;

  _FakeDestinationRepository(this._items);

  @override
  Future<List<Destination>> fetchDestinations({DestinationQueryOptions? options}) async {
    return _items;
  }
}

Destination _destination() {
  return Destination(
    id: 'd1',
    name: 'Paris',
    description: 'desc',
    location: 'France',
    rating: 4.8,
    price: 250,
    images: const <String>['https://example.com/p.jpg'],
    activities: const <String>['Walk'],
    isFeatured: true,
    category: 'City',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Request info sheet validates preferred contact before continuing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<AnalyticsService>.value(value: const NoopAnalyticsService()),
          ChangeNotifierProvider(
            create: (_) => DestinationProvider(
              repository: _FakeDestinationRepository(<Destination>[_destination()]),
            ),
          ),
          ChangeNotifierProvider(create: (_) => FavoritesProvider()),
          ChangeNotifierProvider(create: (_) => PersonalizationProvider()),
        ],
        child: const MaterialApp(
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            Locale('en'),
            Locale('de'),
            Locale('fr'),
          ],
          home: DestinationDetailScreen(destinationId: 'd1'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Request Info'));
    await tester.pumpAndSettle();

    expect(find.text('Request destination info'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pump();

    expect(find.text('Please enter your preferred contact.'), findsOneWidget);
  });
}
