import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// "12 Oct 2026" / "12 oct. 2026" / "12. Okt. 2026", in the app language.
String formatDate(BuildContext context, DateTime date) =>
    DateFormat.yMMMd(Localizations.localeOf(context).toString()).format(date);
