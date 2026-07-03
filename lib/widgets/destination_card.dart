import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../screens/destination_detail_screen.dart';
import 'booking_dialog.dart';

class DestinationCard extends StatelessWidget {
  final Destination destination;

  const DestinationCard({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    final hasDiscount = destination.discount > 0;
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => 
                DestinationDetailScreen(destinationId: destination.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardHeight = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 200.0;
            final imageHeight = (cardHeight * 0.52).clamp(82.0, 116.0).toDouble();
            final isCompact = cardHeight < 205;
            final isVeryCompact = cardHeight < 190;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image section
                Stack(
                  children: [
                    SizedBox(
                      height: imageHeight,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          destination.images.first,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.photo,
                                size: 30,
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (hasDiscount)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isCompact ? 6 : 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.error,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${(destination.discount * 100).toInt()}% OFF',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 9 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Content section
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 8 : 10,
                      isCompact ? 8 : 10,
                      isCompact ? 8 : 10,
                      isCompact ? 6 : 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          destination.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isCompact ? 12 : 13,
                            height: 1.1,
                          ),
                          maxLines: isVeryCompact ? 1 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!isVeryCompact) ...[
                          const SizedBox(height: 2),
                          Text(
                            destination.location,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: isCompact ? 10 : 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: isCompact ? 11 : 12,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              destination.rating.toString(),
                              style: TextStyle(
                                fontSize: isCompact ? 10 : 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const Spacer(),
                            if (hasDiscount && !isVeryCompact)
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Text(
                                  '\$${destination.price.toInt()}',
                                  style: const TextStyle(
                                    fontSize: 9,
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                            Text(
                              '\$${destination.discountedPrice.toInt()}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isCompact ? 11 : 12,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isVeryCompact ? 3 : 6),
                        SizedBox(
                          width: double.infinity,
                          height: isVeryCompact ? 22 : (isCompact ? 24 : 28),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    BookingDialog(destination: destination),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: Text(
                              'Book Now',
                              style: TextStyle(fontSize: isVeryCompact ? 9 : 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}