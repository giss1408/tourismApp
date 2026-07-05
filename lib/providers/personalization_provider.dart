import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/destination_model.dart';

class PersonalizationProvider with ChangeNotifier {
  static const String _recentlyViewedKey = 'personalization_recently_viewed_ids';
  static const String _categoryInterestKey = 'personalization_category_interest';
  static const String _preferredBudgetKey = 'personalization_preferred_budget';
  static const int _maxRecentlyViewed = 20;

  final List<String> _recentlyViewedIds = <String>[];
  final Map<String, int> _categoryInterest = <String, int>{};
  double? _preferredBudget;

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<String> get recentlyViewedIds => List<String>.unmodifiable(_recentlyViewedIds);
  double? get preferredBudget => _preferredBudget;

  PersonalizationProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();

    _recentlyViewedIds
      ..clear()
      ..addAll(prefs.getStringList(_recentlyViewedKey) ?? const <String>[]);

    final categoryRaw = prefs.getString(_categoryInterestKey);
    if (categoryRaw != null && categoryRaw.isNotEmpty) {
      try {
        final decoded = jsonDecode(categoryRaw);
        if (decoded is! Map) {
          throw const FormatException('Category interest cache is not a map.');
        }

        _categoryInterest
          ..clear()
          ..addEntries(
            decoded.entries
                .where((entry) => entry.key is String && entry.value is num)
                .map(
                  (entry) => MapEntry(
                    entry.key as String,
                    (entry.value as num).toInt(),
                  ),
                ),
          );
      } catch (_) {
        _categoryInterest.clear();
        await prefs.remove(_categoryInterestKey);
      }
    }

    _preferredBudget = prefs.getDouble(_preferredBudgetKey);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentlyViewedKey, _recentlyViewedIds);
    await prefs.setString(_categoryInterestKey, jsonEncode(_categoryInterest));

    if (_preferredBudget != null) {
      await prefs.setDouble(_preferredBudgetKey, _preferredBudget!);
    } else {
      await prefs.remove(_preferredBudgetKey);
    }
  }

  Future<void> trackView(Destination destination) async {
    if (destination.id.isEmpty) {
      return;
    }

    // Avoid noisy writes when rebuilding same detail screen repeatedly.
    if (_recentlyViewedIds.isNotEmpty && _recentlyViewedIds.first == destination.id) {
      return;
    }

    _recentlyViewedIds.remove(destination.id);
    _recentlyViewedIds.insert(0, destination.id);
    if (_recentlyViewedIds.length > _maxRecentlyViewed) {
      _recentlyViewedIds.removeRange(_maxRecentlyViewed, _recentlyViewedIds.length);
    }

    if (destination.category.isNotEmpty) {
      _categoryInterest.update(destination.category, (count) => count + 1, ifAbsent: () => 1);
    }

    final viewedPrice = destination.discountedPrice;
    _preferredBudget = _preferredBudget == null
        ? viewedPrice
        : ((_preferredBudget! * 0.75) + (viewedPrice * 0.25));

    await _save();
    notifyListeners();
  }

  List<Destination> recommendations(
    List<Destination> allDestinations, {
    int limit = 6,
  }) {
    if (allDestinations.isEmpty) {
      return const <Destination>[];
    }

    final viewed = _recentlyViewedIds.toSet();

    final candidates = allDestinations
        .where((destination) => !viewed.contains(destination.id))
        .toList(growable: false);

    if (candidates.isEmpty) {
      return allDestinations.take(limit).toList(growable: false);
    }

    final scored = candidates
        .map((destination) => _ScoredDestination(
              destination,
              _scoreDestination(destination),
            ))
        .toList(growable: false)
      ..sort((a, b) => b.score.compareTo(a.score));

    return scored.take(limit).map((entry) => entry.destination).toList(growable: false);
  }

  double _scoreDestination(Destination destination) {
    double score = destination.rating * 2.5;

    final categoryWeight = _categoryInterest[destination.category] ?? 0;
    score += categoryWeight * 3;

    if (destination.isFeatured) {
      score += 2;
    }

    if (_preferredBudget != null) {
      final diff = (destination.discountedPrice - _preferredBudget!).abs();
      // Closer budgets get up to +12 points.
      final budgetBoost = (12 - (diff / 40)).clamp(0, 12);
      score += budgetBoost;
    }

    if (destination.discount > 0) {
      score += destination.discount * 10;
    }

    return score;
  }
}

class _ScoredDestination {
  final Destination destination;
  final double score;

  const _ScoredDestination(this.destination, this.score);
}
