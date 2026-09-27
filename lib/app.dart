import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';
import 'screens/destinations_screen.dart';
import 'screens/booking_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/map_screen.dart';
import 'theme/app_theme.dart';
import 'providers/theme_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'providers/payment_methods_provider.dart';
import 'l10n/app_localizations.dart';
import 'providers/app_settings_provider.dart';
import 'repositories/travel_repository.dart';
import 'services/push_service.dart';
import 'widgets/common/consent_dialog.dart';

class TourismApp extends StatelessWidget {
  const TourismApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
  
    return MaterialApp(
      title: 'Akwaba Ivoire',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: context.read<GlobalKey<ScaffoldMessengerState>>(),
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: context.watch<ThemeProvider>().themeMode,
      locale: languageProvider.locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('de'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Show loading while checking auth state
    if (authProvider.isLoading && authProvider.user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Show auth screen if not logged in, otherwise main app
    return authProvider.isLoggedIn ? const MainNavigation() : const AuthScreen();
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  String? _syncedLanguage;

  /// Signed-in start-up: consent, push registration, and the operator
  /// settings and emails in the traveller's language.
  Future<void> _startSession() async {
    await showConsentDialogIfNeeded(context);
    if (!mounted) return;
    await context.read<PushService>().enable();
  }

  void _syncLanguage(String language) {
    if (language == _syncedLanguage) return;
    _syncedLanguage = language;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppSettingsProvider>().load(language);
      context.read<TravelRepository>().updateLanguage(language).catchError((_) {});
    });
  }

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _startSession();
    });
    _screens = [
      const HomeScreen(),
      const DestinationsScreen(),
      const MapScreen(),
      const BookingScreen(),
      Builder(
        builder: (context) {
          final paymentMethodsProvider = Provider.of<PaymentMethodsProvider?>(
            context,
            listen: false,
          );

          if (paymentMethodsProvider != null) {
            return ChangeNotifierProvider<PaymentMethodsProvider>.value(
              value: paymentMethodsProvider,
              child: const ProfileScreen(),
            );
          }

          return ChangeNotifierProvider<PaymentMethodsProvider>(
            create: (_) => PaymentMethodsProvider(),
            child: const ProfileScreen(),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 800;
    final localizations = AppLocalizations.of(context);
    _syncLanguage(context.watch<LanguageProvider>().locale.languageCode);

    if (kIsWeb && isLargeScreen) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              labelType: NavigationRailLabelType.all,
              destinations: [
                NavigationRailDestination(
                  icon: const Icon(Icons.home),
                  label: Text(localizations.home),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.explore),
                  label: Text(localizations.explore),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.map_outlined),
                  label: Text(localizations.translate('mapTab')),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.bookmark),
                  label: Text(localizations.bookings),
                ),
                NavigationRailDestination(
                  icon: const Icon(Icons.person),
                  label: Text(localizations.profile),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          ],
        ),
      );
    } else {
      return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home),
              label: localizations.home,
            ),
            NavigationDestination(
              icon: const Icon(Icons.explore),
              label: localizations.explore,
            ),
            NavigationDestination(
              icon: const Icon(Icons.map_outlined),
              label: localizations.translate('mapTab'),
            ),
            NavigationDestination(
              icon: const Icon(Icons.bookmark),
              label: localizations.bookings,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person),
              label: localizations.profile,
            ),
          ],
        ),
      );
    }
  }
}