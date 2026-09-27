import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/booking_provider.dart';
import '../utils/dates.dart';
import '../utils/money.dart';

class TripInfoScreen extends StatelessWidget {
  final Booking booking;

  const TripInfoScreen({super.key, required this.booking});


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final confirmed = booking.status == 'Confirmed';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.tripDetailsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      confirmed
                          ? Icon(Icons.verified, color: Colors.green.shade600)
                          : Icon(Icons.hourglass_top,
                              color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          confirmed
                              ? localizations.bookingConfirmedTitle
                              : localizations.translate('bookingPendingTitle'),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  if (!confirmed) ...[
                    const SizedBox(height: 4),
                    Text(localizations.translate('bookingPendingSubtitle')),
                  ],
                  const SizedBox(height: 8),
                  Text('${localizations.referenceLabel}: ${booking.reference}'),
                  Text('${localizations.destinationLabel}: ${booking.destinationName}'),
                  Text('${localizations.location}: ${booking.location}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.tripSummaryTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _InfoRow(label: localizations.checkIn, value: formatDate(context, booking.checkInDate)),
                  _InfoRow(label: localizations.checkOut, value: formatDate(context, booking.checkOutDate)),
                  _InfoRow(label: localizations.guests, value: '${booking.guests}'),
                  _InfoRow(label: localizations.nights, value: '${booking.nights}'),
                  _InfoRow(
                    label: confirmed
                        ? localizations.totalPaidLabel
                        : localizations.translate('totalDueLabel'),
                    value: Money.eurWithXof(context, booking.totalPrice, cents: true),
                    isStrong: true,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.whatHappensNextTitle,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 10),
                  _StepItem(
                    icon: Icons.email_outlined,
                    text: localizations.tripNextStepEmail,
                  ),
                  _StepItem(
                    icon: Icons.badge_outlined,
                    text: localizations.tripNextStepReference,
                  ),
                  _StepItem(
                    icon: Icons.support_agent,
                    text: localizations.tripNextStepSupport,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(localizations.doneAction),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isStrong;

  const _InfoRow({required this.label, required this.value, this.isStrong = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: isStrong ? FontWeight.bold : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StepItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
