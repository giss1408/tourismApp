import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  /// Last full catalogue, shown at start-up and when the network fails.
  static const _cacheKey = 'destinations_cache_v1';

  /// True while showing cached data because the refresh failed.
  bool _isOffline = false;
  bool get isOffline => _isOffline;

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

    // Cache first: the catalogue shows instantly, then refreshes.
    final fullCatalogue = options == null;
    if (fullCatalogue && _destinations.isEmpty) {
      final cached = await _readCache();
      if (cached.isNotEmpty) {
        _destinations = cached;
        _featuredDestinations = cached.where((d) => d.isFeatured).toList();
        notifyListeners();
      }
    }

    try {
      _destinations = await _repository.fetchDestinations(options: options);
      _error = '';
      _isOffline = false;
      _status = DestinationDataStatus.success;
      if (fullCatalogue) await _writeCache(_destinations);
    } catch (e, st) {
      if (kDebugMode) debugPrint('[DestinationProvider] $e\n$st');
      final cached = fullCatalogue ? await _readCache() : <Destination>[];
      if (cached.isNotEmpty) {
        _destinations = cached;
        _isOffline = true;
        _error = '';
        _status = DestinationDataStatus.success;
      } else {
        _error = 'Unable to load destinations. Check your connection and try again.';
        _destinations = [];
        _status = DestinationDataStatus.error;
      }
    } finally {
      _featuredDestinations = _destinations.where((d) => d.isFeatured).toList();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Destination>> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null) return [];
      return (jsonDecode(raw) as List<dynamic>)
          .map((item) => Destination.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return []; // Corrupt or outdated cache: ignore it.
    }
  }

  Future<void> _writeCache(List<Destination> destinations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          _cacheKey, jsonEncode(destinations.map((d) => d.toJson()).toList()));
    } catch (_) {}
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