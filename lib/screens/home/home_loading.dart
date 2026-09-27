import 'package:flutter/material.dart';

import '../../utils/responsive_layout.dart';
import '../../widgets/loading_destination_card.dart';

class LoadingFeaturedDestinations extends StatelessWidget {
  const LoadingFeaturedDestinations({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return Container(
            width: ResponsiveLayout.featuredCardWidth(context),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
            ),
          );
        },
      ),
    );
  }
}

class LoadingDestinationsGrid extends StatelessWidget {
  const LoadingDestinationsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveLayout.destinationGridCount(context),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: ResponsiveLayout.destinationCardAspectRatio(
            ResponsiveLayout.destinationGridCount(context)),
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const LoadingDestinationCard(),
        childCount: 6,
      ),
    );
  }
}
