import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/booking_provider.dart';
import 'bookings/booking_card.dart';
import 'destinations_screen.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bookings = context.watch<BookingProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(t.myBookings)),
      body: RefreshIndicator(
        onRefresh: bookings.loadBookings,
        child: bookings.bookings.isEmpty
            ? ListView(
                children: [
                  const SizedBox(height: 120),
                  Icon(Icons.luggage_outlined, size: 64, color: Theme.of(context).hintColor),
                  const SizedBox(height: 16),
                  Text(t.translate('noBookingsYet'),
                      textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 8),
                  Text(t.translate('startExploring'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor)),
                  const SizedBox(height: 20),
                  Center(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const DestinationsScreen()),
                      ),
                      child: Text(t.exploreDestinations),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: bookings.bookings.length,
                itemBuilder: (context, index) =>
                    BookingCard(booking: bookings.bookings[index]),
              ),
      ),
    );
  }
}
