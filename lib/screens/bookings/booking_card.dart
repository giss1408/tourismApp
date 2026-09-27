import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/booking_provider.dart';
import '../../utils/dates.dart';
import '../../utils/money.dart';
import '../../widgets/optimized_network_image.dart';
import 'booking_dialogs.dart';

class BookingCard extends StatelessWidget {
  final Booking booking;

  const BookingCard({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final muted = Theme.of(context).hintColor;
    final cancelled = booking.status == 'Cancelled';
    final pending = booking.status == 'Pending';
    final paymentsEnabled =
        context.watch<AppSettingsProvider>().settings.paymentsEnabled;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: booking.destinationImage.isEmpty
                      ? Container(
                          width: 80, height: 80,
                          color: colors.primaryContainer,
                          child: Icon(Icons.landscape, color: colors.onPrimaryContainer))
                      : OptimizedNetworkImage(
                          imageUrl: booking.destinationImage,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.reference,
                          style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text(booking.destinationName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(booking.location, style: TextStyle(color: muted)),
                      const SizedBox(height: 8),
                      BookingStatusChip(status: booking.status),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Detail(t.checkIn, formatDate(context, booking.checkInDate)),
                _Detail(t.checkOut, formatDate(context, booking.checkOutDate)),
                _Detail(t.translate('guestsLabel'), '${booking.guests}'),
                _Detail(t.translate('nightsLabel'), '${booking.nights}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.total, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Flexible(
                  child: Text(
                    Money.eurWithXof(context, booking.totalPrice, cents: true),
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: colors.primary),
                  ),
                ),
              ],
            ),
            if (pending && paymentsEnabled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => payForBooking(context, booking),
                  icon: const Icon(Icons.lock_outline),
                  label: Text(t.translate('payNow')),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showBookingDetails(context, booking),
                    child: Text(t.viewDetails),
                  ),
                ),
                if (!cancelled) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => showModifyBookingDialog(context, booking),
                      child: Text(t.modify),
                    ),
                  ),
                ],
              ],
            ),
            if (!cancelled)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: colors.error),
                  onPressed: () => confirmCancelBooking(context, booking),
                  icon: const Icon(Icons.cancel_outlined),
                  label: Text(t.translate('cancelBooking')),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class BookingStatusChip extends StatelessWidget {
  final String status;

  const BookingStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (color, label) = switch (status) {
      'Confirmed' => (Colors.green.shade700, t.confirmed),
      'Pending' => (Colors.orange.shade800, t.pending),
      'Cancelled' => (Colors.red.shade700, t.cancelled),
      _ => (Colors.grey.shade700, status),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
      child: Text(label.toUpperCase(),
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;

  const _Detail(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
