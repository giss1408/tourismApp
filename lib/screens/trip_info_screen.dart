import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../providers/booking_provider.dart';

class TripInfoScreen extends StatelessWidget {
  final Booking booking;

  const TripInfoScreen({super.key, required this.booking});

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

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
                      Icon(Icons.verified, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          localizations.bookingConfirmedTitle,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
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
                  _InfoRow(label: localizations.checkIn, value: _formatDate(booking.checkInDate)),
                  _InfoRow(label: localizations.checkOut, value: _formatDate(booking.checkOutDate)),
                  _InfoRow(label: localizations.guests, value: '${booking.guests}'),
                  _InfoRow(label: localizations.nights, value: '${booking.nights}'),
                  _InfoRow(
                    label: localizations.totalPaidLabel,
                    value: '\$${booking.totalPrice.toStringAsFixed(2)}',
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
