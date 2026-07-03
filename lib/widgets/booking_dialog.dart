// widgets/booking_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination_model.dart';
import '../providers/booking_provider.dart';

class BookingDialog extends StatefulWidget {
  final Destination destination;

  const BookingDialog({super.key, required this.destination});

  @override
  State<BookingDialog> createState() => _BookingDialogState();
}

class _BookingDialogState extends State<BookingDialog> {
  int _guests = 1;
  int _nights = 3;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 7));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 10));

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.read<BookingProvider>();
    final totalPrice = widget.destination.discountedPrice * _guests * _nights;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.destination.images.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[200],
                        child: const Icon(Icons.photo),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.destination.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.destination.location,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Booking Details
            const Text(
              'Booking Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Guests
            _buildNumberSelector(
              'Number of Guests',
              _guests,
              (value) => setState(() => _guests = value),
              1,
              10,
            ),
            
            const SizedBox(height: 16),
            
            // Nights
            _buildNumberSelector(
              'Number of Nights',
              _nights,
              (value) => setState(() => _nights = value),
              1,
              30,
            ),
            
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            
            // Price Breakdown
            const Text(
              'Price Breakdown',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            
            _buildPriceRow('Price per night', '\$${widget.destination.discountedPrice.toStringAsFixed(2)}'),
            _buildPriceRow('$_nights nights', '\$${(widget.destination.discountedPrice * _nights).toStringAsFixed(2)}'), // FIXED: Changed $nights to $_nights
            _buildPriceRow('$_guests guests', '\$${(widget.destination.discountedPrice * _nights * _guests).toStringAsFixed(2)}'),
            
            if (widget.destination.discount > 0)
              _buildPriceRow(
                'Discount (${(widget.destination.discount * 100).toInt()}%)',
                '-\$${(widget.destination.price * _nights * _guests * widget.destination.discount).toStringAsFixed(2)}',
                isDiscount: true,
              ),
            
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Action Buttons
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
                      _bookNow(bookingProvider, totalPrice);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelector(String label, int value, Function(int) onChanged, int min, int max) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: value > min ? () => onChanged(value - 1) : null,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: value < max ? () => onChanged(value + 1) : null,
        ),
      ],
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? Colors.green : Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _bookNow(BookingProvider bookingProvider, double totalPrice) {
    final booking = Booking(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      destinationName: widget.destination.name,
      destinationImage: widget.destination.images.first,
      location: widget.destination.location,
      bookingDate: DateTime.now(),
      checkInDate: _checkInDate,
      checkOutDate: _checkOutDate,
      guests: _guests,
      nights: _nights,
      totalPrice: totalPrice,
      status: 'Confirmed',
    );

    bookingProvider.addBooking(booking);
    
    Navigator.pop(context); // Close dialog
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully booked ${widget.destination.name}!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}