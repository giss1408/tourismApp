import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Prices are in euros, the currency of our European travellers. The CFA
/// franc (XOF), used on site in Côte d'Ivoire, is pegged to the euro.
class Money {
  Money._();

  /// Fixed EUR → XOF parity.
  static const xofPerEur = 655.957;

  /// Flat fee added to each booking; the backend charges the same
  /// (BOOKING_SERVICE_FEE_EUR).
  static const serviceFeeEur = 29.0;

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toString();

  /// "€249" / "249 €", following the app language.
  static String eur(BuildContext context, num amount, {bool cents = false}) =>
      NumberFormat.currency(
        locale: _locale(context),
        symbol: '€',
        decimalDigits: cents ? 2 : 0,
      ).format(amount);

  /// The same amount in CFA francs, e.g. "163 333 FCFA".
  static String xof(BuildContext context, num amountEur) =>
      '${NumberFormat.decimalPattern(_locale(context)).format((amountEur * xofPerEur).round())} FCFA';

  /// "€249 · 163,333 FCFA", for totals where travellers budget on site.
  static String eurWithXof(BuildContext context, num amount,
          {bool cents = false}) =>
      '${eur(context, amount, cents: cents)} · ${xof(context, amount)}';
}
