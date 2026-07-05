import 'package:flutter/material.dart';

import '../models/destination_model.dart';

typedef DestinationImagePrefetcher = Future<void> Function(
  BuildContext context,
  String imageUrl,
);

class ImagePrefetchService {
  static String _lastSignature = '';
  static DestinationImagePrefetcher? _testPrefetchOverride;

  static Future<void> _defaultPrefetch(
    BuildContext context,
    String imageUrl,
  ) {
    return precacheImage(NetworkImage(imageUrl), context);
  }

  static void resetForTest() {
    _lastSignature = '';
    _testPrefetchOverride = null;
  }

  static void setTestPrefetchOverride(DestinationImagePrefetcher? override) {
    _testPrefetchOverride = override;
  }

  static Future<void> prefetchDestinations(
    BuildContext context,
    List<Destination> destinations, {
    int limit = 12,
    DestinationImagePrefetcher? prefetchImage,
  }) async {
    if (destinations.isEmpty) {
      return;
    }

    final urls = destinations
        .where((destination) => destination.images.isNotEmpty)
        .take(limit)
        .map((destination) => destination.images.first)
        .toList(growable: false);

    if (urls.isEmpty) {
      return;
    }

    final signature = urls.join('|');
    if (signature == _lastSignature) {
      return;
    }
    _lastSignature = signature;

    final prefetch = prefetchImage ?? _testPrefetchOverride ?? _defaultPrefetch;

    for (final url in urls) {
      await prefetch(context, url);
    }
  }
}
