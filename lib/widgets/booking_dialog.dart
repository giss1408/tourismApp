import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../providers/booking_provider.dart';
import '../screens/trip_info_screen.dart';
import '../services/analytics_service.dart';

class BookingDialog extends StatefulWidget {
  final Destination destination;

  const BookingDialog({super.key, required this.destination});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  int _guests = 1;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 10));
  String _notes = '';
  bool _reviewStep = false;

  int get _nights {
    final diff = _checkOutDate.difference(_checkInDate).inDays;
    return diff <= 0 ? 1 : diff;
  }

  double get _totalPrice {
    return widget.destination.discountedPrice * _guests * _nights;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: _reviewStep ? _buildReviewStep(context) : _buildSetupStep(context),
        ),
      ),
    );
  }

  Widget _buildSetupStep(BuildContext context) {
    return Column(
      key: const ValueKey('setup-step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 18),
        const Text(
          'Plan your trip',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        _buildDateTile(
          label: 'Check-in',
          date: _checkInDate,
          onTap: () => _pickDate(isCheckIn: true),
        ),
        const SizedBox(height: 10),
        _buildDateTile(
          label: 'Check-out',
          date: _checkOutDate,
          onTap: () => _pickDate(isCheckIn: false),
        ),
        const SizedBox(height: 10),
        _buildNumberSelector(
          label: 'Guests',
          value: _guests,
          min: 1,
          max: 10,
          onChanged: (value) => setState(() => _guests = value),
        ),
        const SizedBox(height: 10),
        TextField(
          minLines: 2,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Notes (optional)',
            hintText: 'Airport pickup, dietary requests, special occasion...',
          ),
          onChanged: (value) => _notes = value,
        ),
        const SizedBox(height: 18),
        _buildSummaryCard(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<AnalyticsService>().trackEvent(
                    'booking_started',
                    properties: <String, Object?>{
                      'destination_id': widget.destination.id,
                      'guests': _guests,
                      'nights': _nights,
                      'estimated_total': _totalPrice + 29,
                    },
                  );
                  setState(() => _reviewStep = true);
                },
                child: const Text('Review Booking'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    return Column(
      key: const ValueKey('review-step'),
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 18),
        const Text(
          'Review & confirm',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 14),
        _buildReviewRow('Dates', '${_formatDate(_checkInDate)} to ${_formatDate(_checkOutDate)}'),
        _buildReviewRow('Guests', _guests.toString()),
        _buildReviewRow('Nights', _nights.toString()),
        if (_notes.trim().isNotEmpty) _buildReviewRow('Notes', _notes.trim()),
        const SizedBox(height: 10),
        _buildPriceBreakdown(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _reviewStep = false),
                child: const Text('Back'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirmBooking,
                child: const Text('Confirm & Book'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader() {
    final hasImage = widget.destination.images.isNotEmpty;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: hasImage
              ? Image.network(
                  widget.destination.images.first,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.photo),
                  ),
                )
              : Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.photo),
                ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.destination.name,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.destination.location,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.event),
      title: Text(label),
      subtitle: Text(_formatDate(date)),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildNumberSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    required ValueChanged<int> onChanged,
  }) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Text(
          '$value',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick summary',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text('$_guests guest(s) • $_nights night(s)'),
          const SizedBox(height: 2),
          Text(
            'Estimated total: \$${_totalPrice.toStringAsFixed(2)}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.tertiary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdown() {
    final base = widget.destination.discountedPrice * _nights * _guests;
    final discountAmount = widget.destination.discount > 0
        ? widget.destination.price * _nights * _guests * widget.destination.discount
        : 0.0;

    return Column(
      children: [
        _buildReviewRow(
          'Base fare',
          '\$${(widget.destination.price * _nights * _guests).toStringAsFixed(2)}',
        ),
        if (widget.destination.discount > 0)
          _buildReviewRow(
            'Discount',
            '-\$${discountAmount.toStringAsFixed(2)}',
            valueColor: Theme.of(context).colorScheme.tertiary,
          ),
        _buildReviewRow('Service fee', '\$29.00'),
        const Divider(),
        _buildReviewRow(
          'Total',
          '\$${(base + 29).toStringAsFixed(2)}',
          isStrong: true,
        ),
      ],
    );
  }

  Widget _buildReviewRow(
    String label,
    String value, {
    Color? valueColor,
    bool isStrong = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isStrong ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontWeight: isStrong ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isCheckIn}) async {
    final initialDate = isCheckIn ? _checkInDate : _checkOutDate;
    final firstDate = isCheckIn ? DateTime.now() : _checkInDate.add(const Duration(days: 1));

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );

    if (selected == null) return;

    setState(() {
      if (isCheckIn) {
        _checkInDate = selected;
        if (!_checkOutDate.isAfter(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      } else {
        _checkOutDate = selected.isAfter(_checkInDate)
            ? selected
            : _checkInDate.add(const Duration(days: 1));
      }
    });
  }

  Future<void> _confirmBooking() async {
    final bookingProvider = context.read<BookingProvider>();
    final navigator = Navigator.of(context);
    final finalTotal = _totalPrice + 29;

    final booking = Booking(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      reference: bookingProvider.generateReference(),
      destinationId: widget.destination.id,
      destinationName: widget.destination.name,
      destinationImage: widget.destination.images.first,
      location: widget.destination.location,
      bookingDate: DateTime.now(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      guests: _guests,
      nights: _nights,
      totalPrice: finalTotal,
      status: 'Confirmed',
      notes: _notes.trim(),
    );

    await bookingProvider.addBooking(booking);

    if (!mounted) {
      return;
    }

    navigator.pop();
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => TripInfoScreen(booking: booking),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
