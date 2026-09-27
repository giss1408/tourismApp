import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/payment_service.dart';
import '../../utils/dates.dart';
import '../../utils/money.dart';

/// Last day the booking can be cancelled with a full refund.
DateTime freeCancellationUntil(BuildContext context, Booking booking) {
  final days = context.read<AppSettingsProvider>().settings.freeCancellationDays;
  return DateUtils.dateOnly(booking.checkInDate).subtract(Duration(days: days));
}

void _snack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating));
}

Future<void> confirmCancelBooking(BuildContext context, Booking booking) async {
  final t = AppLocalizations.of(context);
  final deadline = freeCancellationUntil(context, booking);
  final refundable = !DateUtils.dateOnly(DateTime.now()).isAfter(deadline);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.translate('cancelBookingTitle')),
      content: Text(refundable
          ? t.translate('cancelFreeUntil')
              .replaceAll('{date}', formatDate(context, deadline))
          : t.translate('cancelNotRefundable')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(t.translate('keepBooking')),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(t.translate('cancelBooking')),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  await context.read<BookingProvider>().cancelBooking(booking.id);
  if (context.mounted) _snack(context, t.translate('bookingCancelled'));
}

Future<void> payForBooking(BuildContext context, Booking booking) async {
  final t = AppLocalizations.of(context);
  final outcome = await context.read<PaymentService>().payBooking(
        booking.reference,
        themeMode: context.read<ThemeProvider>().themeMode,
      );
  if (!context.mounted) return;
  _snack(context, t.translate(switch (outcome) {
    PaymentOutcome.paid => 'paymentSuccess',
    PaymentOutcome.cancelled => 'paymentCancelled',
    PaymentOutcome.unavailable => 'paymentsUnavailable',
    PaymentOutcome.failed => 'paymentFailed',
  }));
  if (outcome == PaymentOutcome.paid) {
    // Stripe notifies the backend, which confirms the booking.
    final bookings = context.read<BookingProvider>();
    await Future<void>.delayed(const Duration(seconds: 3));
    await bookings.loadBookings();
  }
}

void showBookingDetails(BuildContext context, Booking booking) {
  final t = AppLocalizations.of(context);
  Widget row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: 110, child: Text(label, style: TextStyle(color: Theme.of(context).hintColor))),
            Expanded(child: Text(value)),
          ],
        ),
      );
  showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.bookingDetails),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          row(t.referenceLabel, booking.reference),
          row(t.destinationLabel, booking.destinationName),
          row(t.checkIn, formatDate(context, booking.checkInDate)),
          row(t.checkOut, formatDate(context, booking.checkOutDate)),
          row(t.translate('guestsLabel'), '${booking.guests}'),
          row(t.translate('nightsLabel'), '${booking.nights}'),
          row(t.total, Money.eurWithXof(context, booking.totalPrice, cents: true)),
          if (booking.status != 'Cancelled')
            row(t.cancellationPolicy,
                t.translate('freeCancellationUntil').replaceAll(
                    '{date}', formatDate(context, freeCancellationUntil(context, booking)))),
          if (booking.notes.isNotEmpty) row(t.translate('notesLabel'), booking.notes),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.translate('close')),
        ),
      ],
    ),
  );
}

void showModifyBookingDialog(BuildContext context, Booking booking) {
  final t = AppLocalizations.of(context);
  final fee = context.read<AppSettingsProvider>().settings.serviceFeeEur;
  // The service fee is per booking, not per night or guest.
  final unitPrice =
      (booking.totalPrice - fee).clamp(0, double.infinity) / booking.nights / booking.guests;
  var guests = booking.guests;
  var checkIn = booking.checkInDate;
  var checkOut = booking.checkOutDate;

  showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (dialogContext, setState) {
        final days = checkOut.difference(checkIn).inDays;
        final nights = days <= 0 ? 1 : days;
        final total = unitPrice * nights * guests + fee;

        Future<void> pick({required bool isCheckIn}) async {
          final picked = await showDatePicker(
            context: dialogContext,
            initialDate: isCheckIn ? checkIn : checkOut,
            firstDate: isCheckIn ? DateTime.now() : checkIn.add(const Duration(days: 1)),
            lastDate: DateTime.now().add(const Duration(days: 730)),
          );
          if (picked == null) return;
          setState(() {
            if (isCheckIn) {
              checkIn = picked;
              if (!checkOut.isAfter(checkIn)) checkOut = checkIn.add(const Duration(days: 1));
            } else {
              checkOut = picked;
            }
          });
        }

        return AlertDialog(
          title: Text(t.translate('modifyBooking')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.checkIn),
                subtitle: Text(formatDate(context, checkIn)),
                trailing: const Icon(Icons.event),
                onTap: () => pick(isCheckIn: true),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(t.checkOut),
                subtitle: Text(formatDate(context, checkOut)),
                trailing: const Icon(Icons.event),
                onTap: () => pick(isCheckIn: false),
              ),
              Row(
                children: [
                  Text(t.translate('guestsLabel')),
                  const Spacer(),
                  IconButton(
                    onPressed: guests > 1 ? () => setState(() => guests--) : null,
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('$guests'),
                  IconButton(
                    onPressed: guests < 10 ? () => setState(() => guests++) : null,
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(t.translate('updatedTotal')
                  .replaceAll('{total}', Money.eur(context, total, cents: true))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () {
                context.read<BookingProvider>().modifyBooking(
                      bookingId: booking.id,
                      checkInDate: checkIn,
                      checkOutDate: checkOut,
                      guests: guests,
                      nights: nights,
                      totalPrice: total,
                    );
                Navigator.pop(dialogContext);
              },
              child: Text(t.save),
            ),
          ],
        );
      },
    ),
  );
}
