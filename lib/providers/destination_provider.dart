import 'package:flutter/foundation.dart';

import '../models/destination_model.dart';
import '../repositories/destination_repository.dart';
import '../repositories/mock_destination_repository.dart';
import '../repositories/query_options.dart';

enum DestinationDataStatus { idle, loading, success, error }

class DestinationProvider with ChangeNotifier {
  final DestinationRepository _repository;

  List<Destination> _destinations = [];
  List<Destination> _featuredDestinations = [];
  bool _isLoading = false;
  String _error = '';
  DestinationDataStatus _status = DestinationDataStatus.idle;

  List<Destination> get destinations => _destinations;
  List<Destination> get featuredDestinations => _featuredDestinations;
  bool get isLoading => _isLoading;
  String get error => _error;
  DestinationDataStatus get status => _status;

  DestinationProvider({DestinationRepository? repository})
      : _repository = repository ?? const MockDestinationRepository() {
    if (kDebugMode) {
      debugPrint('[DestinationProvider] init with repository: ${_repository.runtimeType}');
    }
    loadDestinations();
  }

  Future<void> loadDestinations({DestinationQueryOptions? options}) async {
    if (kDebugMode) {
      debugPrint('[DestinationProvider] loadDestinations called, status=$_status');
    }
    _status = DestinationDataStatus.loading;
    _isLoading = true;
    notifyListeners();

    try {
      _destinations = await _repository.fetchDestinations(options: options);
      _error = '';
      _status = DestinationDataStatus.success;
      if (kDebugMode) {
        debugPrint('[DestinationProvider] loaded ${_destinations.length} destinations');
      }
    } catch (e, st) {
      _error = 'Failed to load destinations: $e';
      _destinations = [];
      _status = DestinationDataStatus.error;
      if (kDebugMode) {
        debugPrint('[DestinationProvider] ERROR: $e');
        debugPrint('[DestinationProvider] STACKTRACE: $st');
      }
    } finally {
      _featuredDestinations = _destinations.where((d) => d.isFeatured).toList();
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Destination> getDestinationsByCategory(String category) {
    if (category == 'All') return _destinations;
    return _destinations.where((d) => d.category == category).toList();
  }

  List<Destination> searchDestinations(String query) {
    if (query.isEmpty) return _destinations;
    return _destinations.where((destination) =>
        destination.name.toLowerCase().contains(query.toLowerCase()) ||
        destination.location.toLowerCase().contains(query.toLowerCase()) ||
        destination.description.toLowerCase().contains(query.toLowerCase())).toList();
  }
}