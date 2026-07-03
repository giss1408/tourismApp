// lib/l10n/app_localizations.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'l10n.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  Map<String, String>? _localizedStrings;

  Future<bool> load() async {
    _localizedStrings = await L10n.load(locale);
    return true;
  }

  String translate(String key) {
    return _localizedStrings?[key] ?? key;
  }

  // App Strings
  String get appTitle => translate('appTitle');
  String get exploreThe => translate('exploreThe');
  String get beautifulWorld => translate('beautifulWorld');
  String get discoverAmazingPlaces => translate('discoverAmazingPlaces');
  String get whereDoYouWantToGo => translate('whereDoYouWantToGo');
  String get exploreByCategory => translate('exploreByCategory');
  String get findPerfectDestination => translate('findPerfectDestination');
  String get specialOffers => translate('specialOffers');
  String get getUpToDiscount => translate('getUpToDiscount');
  String get bookNowSaveBig => translate('bookNowSaveBig');
  String get featuredDestinations => translate('featuredDestinations');
  String get mostPopularPlaces => translate('mostPopularPlaces');
  String get allDestinations => translate('allDestinations');
  String get exploreAllAmazingPlaces => translate('exploreAllAmazingPlaces');
  String get searchDestinations => translate('searchDestinations');
  String get destinationsFound => translate('destinationsFound');
  String get noDestinationsFound => translate('noDestinationsFound');
  String get tryAdjustingSearch => translate('tryAdjustingSearch');
  String get exploreDestinations => translate('exploreDestinations');
  String get myBookings => translate('myBookings');
  String get profile => translate('profile');
  String get home => translate('home');
  String get explore => translate('explore');
  String get bookings => translate('bookings');
  String get settings => translate('settings');
  String get darkMode => translate('darkMode');
  String get language => translate('language');
  String get currency => translate('currency');
  String get english => translate('english');
  String get german => translate('german');
  String get french => translate('french');
  String get signIn => translate('signIn');
  String get signUp => translate('signUp');
  String get email => translate('email');
  String get password => translate('password');
  String get confirmPassword => translate('confirmPassword');
  String get fullName => translate('fullName');
  String get forgotPassword => translate('forgotPassword');
  String get dontHaveAccount => translate('dontHaveAccount');
  String get alreadyHaveAccount => translate('alreadyHaveAccount');
  String get orContinueWith => translate('orContinueWith');
  String get createAccount => translate('createAccount');
  String get welcomeBack => translate('welcomeBack');
  String get joinUsToExplore => translate('joinUsToExplore');
  String get resetPassword => translate('resetPassword');
  String get enterYourEmail => translate('enterYourEmail');
  String get send => translate('send');
  String get cancel => translate('cancel');
  String get logout => translate('logout');
  String get areYouSureLogout => translate('areYouSureLogout');
  String get travelStats => translate('travelStats');
  String get trips => translate('trips');
  String get countries => translate('countries');
  String get reviews => translate('reviews');
  String get upcoming => translate('upcoming');
  String get quickActions => translate('quickActions');
  String get wallet => translate('wallet');
  String get rewards => translate('rewards');
  String get help => translate('help');
  String get share => translate('share');
  String get preferences => translate('preferences');
  String get pushNotifications => translate('pushNotifications');
  String get account => translate('account');
  String get privacySecurity => translate('privacySecurity');
  String get paymentMethods => translate('paymentMethods');
  String get helpSupport => translate('helpSupport');
  String get aboutExploreWorld => translate('aboutExploreWorld');
  String get bookNow => translate('bookNow');
  String get price => translate('price');
  String get rating => translate('rating');
  String get location => translate('location');
  String get activities => translate('activities');
  String get description => translate('description');
  String get gallery => translate('gallery');
  String get whatsIncluded => translate('whatsIncluded');
  String get accommodation => translate('accommodation');
  String get meals => translate('meals');
  String get transportation => translate('transportation');
  String get tourGuide => translate('tourGuide');
  String get startingFrom => translate('startingFrom');
  String get save => translate('save');
  String get aboutThisDestination => translate('aboutThisDestination');
  String get popularActivities => translate('popularActivities');
  String get numberGuests => translate('numberGuests');
  String get numberNights => translate('numberNights');
  String get bookingDetails => translate('bookingDetails');
  String get priceBreakdown => translate('priceBreakdown');
  String get pricePerNight => translate('pricePerNight');
  String get nights => translate('nights');
  String get guests => translate('guests');
  String get discount => translate('discount');
  String get total => translate('total');
  String get viewDetails => translate('viewDetails');
  String get modify => translate('modify');
  String get checkIn => translate('checkIn');
  String get checkOut => translate('checkOut');
  String get confirmed => translate('confirmed');
  String get pending => translate('pending');
  String get cancelled => translate('cancelled');
  String get editProfile => translate('editProfile');
  String get displayName => translate('displayName');
  String get signInToContinue => translate('signInToContinue');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}