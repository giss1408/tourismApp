import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/destination_model.dart';
import '../providers/destination_provider.dart';
import 'destination_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DestinationProvider>();
      if (provider.destinations.isEmpty && !provider.isLoading) {
        provider.loadDestinations();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DestinationProvider>();
    final destinations = provider.destinations;
    final markers = _buildDestinationMarkers(destinations);
    final center = _computeCenter(markers);

    return Scaffold(
      appBar: AppBar(title: const Text('Map Explorer')),
      body: RefreshIndicator(
        onRefresh: () => context.read<DestinationProvider>().loadDestinations(),
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: center,
                            initialZoom: markers.isEmpty ? 1.8 : 2.8,
                            interactionOptions: const InteractionOptions(
                              flags: InteractiveFlag.all,
                            ),
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.exploreworld.app',
                              maxZoom: 18,
                            ),
                            MarkerLayer(markers: markers),
                          ],
                        ),
                      ),
                    ),
                    if (provider.isLoading)
                      const Positioned.fill(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (destinations.isEmpty && !provider.isLoading)
                      Positioned.fill(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withOpacity(0.94),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'No destinations yet. Pull down to refresh.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    if (markers.isNotEmpty)
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: FilledButton.icon(
                          onPressed: () => _mapController.move(center, 2.8),
                          icon: const Icon(Icons.public),
                          label: const Text('World View'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 4,
              child: destinations.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      children: const [
                        ListTile(
                          title: Text('Map will populate when destinations load.'),
                          subtitle: Text('Swipe down to refresh data.'),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: destinations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final destination = destinations[index];
                        final point = _resolveCoordinates(destination);

                        return ListTile(
                          tileColor: Theme.of(context).colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                              .withOpacity(0.12),
                            child: Text('${index + 1}'),
                          ),
                          title: Text(destination.name),
                          subtitle: Text(
                            '${destination.location} • ${destination.category}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Text(
                            '\$${destination.discountedPrice.toInt()}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.tertiary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onLongPress: () => _mapController.move(point, 7.5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DestinationDetailScreen(
                                  destinationId: destination.id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<Marker> _buildDestinationMarkers(List<Destination> destinations) {
    return destinations
        .asMap()
        .entries
        .map(
          (entry) => Marker(
            point: _resolveCoordinates(entry.value),
            width: 46,
            height: 46,
            child: _NumberedMarker(
              index: entry.key + 1,
              label: entry.value.name,
            ),
          ),
        )
        .toList(growable: false);
  }

  LatLng _computeCenter(List<Marker> markers) {
    if (markers.isEmpty) {
      return const LatLng(20.0, 0.0);
    }

    double latSum = 0;
    double lngSum = 0;

    for (final marker in markers) {
      latSum += marker.point.latitude;
      lngSum += marker.point.longitude;
    }

    return LatLng(latSum / markers.length, lngSum / markers.length);
  }

  LatLng _resolveCoordinates(Destination destination) {
    if (destination.latitude != null && destination.longitude != null) {
      return LatLng(destination.latitude!, destination.longitude!);
    }

    final byId = _knownByDestinationId[destination.id];
    if (byId != null) {
      return byId;
    }

    final location = destination.location.toLowerCase();
    for (final entry in _knownByKeyword.entries) {
      if (location.contains(entry.key)) {
        return entry.value;
      }
    }

    final hash = destination.id.hashCode.abs();
    final lat = (-35 + (hash % 120) * 0.6).clamp(-80.0, 80.0);
    final lng = (-170 + (hash % 340) * 1.0).clamp(-180.0, 180.0);
    return LatLng(lat, lng);
  }
}

const Map<String, LatLng> _knownByDestinationId = {
  '1': LatLng(-8.4095, 115.1889),
  '2': LatLng(35.6762, 139.6503),
  '3': LatLng(46.6863, 7.8632),
  'dest_101': LatLng(36.3932, 25.4615),
  'dest_102': LatLng(-13.1631, -72.5450),
  'dest_103': LatLng(-8.5069, 115.2625),
  'dest_104': LatLng(35.0116, 135.7681),
  'dest_105': LatLng(46.0207, 7.7491),
  'dest_106': LatLng(40.7128, -74.0060),
  'dest_107': LatLng(-33.9628, 18.4098),
};

const Map<String, LatLng> _knownByKeyword = {
  'bali': LatLng(-8.4095, 115.1889),
  'tokyo': LatLng(35.6762, 139.6503),
  'switzerland': LatLng(46.8182, 8.2275),
  'interlaken': LatLng(46.6863, 7.8632),
  'santorini': LatLng(36.3932, 25.4615),
  'peru': LatLng(-9.1900, -75.0152),
  'kyoto': LatLng(35.0116, 135.7681),
  'zermatt': LatLng(46.0207, 7.7491),
  'new york': LatLng(40.7128, -74.0060),
  'cape town': LatLng(-33.9249, 18.4241),
  'greece': LatLng(39.0742, 21.8243),
  'japan': LatLng(36.2048, 138.2529),
  'indonesia': LatLng(-0.7893, 113.9213),
};

class _NumberedMarker extends StatelessWidget {
  final int index;
  final String label;

  const _NumberedMarker({required this.index, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: '$index. $label',
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.location_on,
            size: 38,
            color: colorScheme.primary,
            shadows: [
              Shadow(
                blurRadius: 8,
                color: colorScheme.shadow.withOpacity(0.35),
              ),
            ],
          ),
          Positioned(
            top: 8,
            child: Text(
              '$index',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
