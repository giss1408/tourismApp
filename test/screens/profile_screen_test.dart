import 'dart:async';

import 'package:explore_world/l10n/app_localizations.dart';
import 'package:explore_world/models/user_model.dart';
import 'package:explore_world/providers/auth_provider.dart';
import 'package:explore_world/providers/language_provider.dart';
import 'package:explore_world/providers/payment_methods_provider.dart';
import 'package:explore_world/providers/theme_provider.dart';
import 'package:explore_world/repositories/auth_repository.dart';
import 'package:explore_world/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _SignedInAuthRepository implements AuthRepository {
  final AppUser _user = AppUser(
    uid: 'u1',
    email: 'user@example.com',
    displayName: 'Traveler',
  );

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.value(_user);

  @override
  Future<AppUser> signInWithEmail(String email, String password) async => _user;

  @override
  Future<AppUser> signUpWithEmail(
    String email,
    String password,
    String displayName,
  ) async => _user;

  @override
  Future<AppUser> signInWithGoogle() async => _user;

  @override
  Future<AppUser> signInWithFacebook() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> resetPassword(String email) async {}
  @override
  Future<void> updateDisplayName(String displayName) async {}
  @override
  Future<void> sendEmailVerification() async {}
  @override
  Future<void> changePassword(String c, String n) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('payment methods bottom sheet can add, set default and remove', (
    WidgetTester tester,
  ) async {
    final authProvider = AuthProvider(repository: _SignedInAuthRepository());
    final paymentProvider = PaymentMethodsProvider();

    await Future<void>.delayed(Duration.zero);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<LanguageProvider>(
            create: (_) => LanguageProvider(),
          ),
          ChangeNotifierProvider<PaymentMethodsProvider>.value(value: paymentProvider),
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
          home: ProfileScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('Payment Methods'));
    await tester.pumpAndSettle();

    final initialCount = paymentProvider.methods.length;

    await tester.tap(find.text('Add mock payment method'));
    await tester.pumpAndSettle();
    expect(paymentProvider.methods.length, initialCount + 1);

    final nonDefaultBefore = paymentProvider.methods
        .firstWhere((method) => !method.isDefault)
        .id;

    await tester.tap(find.byTooltip('Set default').first);
    await tester.pumpAndSettle();

    expect(
      paymentProvider.methods.firstWhere((method) => method.id == nonDefaultBefore).isDefault,
      isTrue,
    );

    await tester.tap(find.byTooltip('Remove method').first);
    await tester.pumpAndSettle();

    expect(paymentProvider.methods.length, initialCount);
    expect(paymentProvider.methods.where((method) => method.isDefault), hasLength(1));

    authProvider.dispose();
    paymentProvider.dispose();
  });
}
