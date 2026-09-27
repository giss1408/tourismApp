import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../repositories/travel_repository.dart';

enum PaymentOutcome { paid, cancelled, failed, unavailable }

/// Pays a booking with Stripe's payment sheet: card, PayPal, Apple Pay or
/// Google Pay, as enabled in the Stripe dashboard. The booking is confirmed
/// by the backend once Stripe reports the payment (webhook), not by the app.
class PaymentService {
  final TravelRepository _repository;

  PaymentService(this._repository);

  Future<PaymentOutcome> payBooking(
    String reference, {
    required ThemeMode themeMode,
  }) async {
    if (kIsWeb) return PaymentOutcome.unavailable;
    try {
      final sheet = await _repository.createBookingPayment(reference);
      Stripe.publishableKey = sheet.publishableKey;
      await Stripe.instance.applySettings();
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: sheet.clientSecret,
          merchantDisplayName: sheet.merchantDisplayName,
          style: themeMode,
          // Required by some payment methods (e.g. PayPal) to return here.
          returnURL: 'akwabaivoire://stripe-redirect',
        ),
      );
      await Stripe.instance.presentPaymentSheet();
      return PaymentOutcome.paid;
    } on StripeException catch (e) {
      return e.error.code == FailureCode.Canceled
          ? PaymentOutcome.cancelled
          : PaymentOutcome.failed;
    } catch (e) {
      if (kDebugMode) debugPrint('[Payment] $e');
      final message = '$e'.toLowerCase();
      return message.contains('not available')
          ? PaymentOutcome.unavailable
          : PaymentOutcome.failed;
    }
  }
}
