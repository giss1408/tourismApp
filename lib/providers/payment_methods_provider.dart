import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethod {
  final String id;
  final String brand;
  final String last4;
  final String holderName;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  const PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.holderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  String get maskedLabel => '$brand •••• $last4';

  String get expiryLabel =>
      '${expiryMonth.toString().padLeft(2, '0')}/${expiryYear.toString().substring(2)}';

  PaymentMethod copyWith({
    bool? isDefault,
  }) {
    return PaymentMethod(
      id: id,
      brand: brand,
      last4: last4,
      holderName: holderName,
      expiryMonth: expiryMonth,
      expiryYear: expiryYear,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'brand': brand,
      'last4': last4,
      'holderName': holderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
    };
  }

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? 'Card',
      last4: json['last4']?.toString() ?? '0000',
      holderName: json['holderName']?.toString() ?? 'Traveler',
      expiryMonth: (json['expiryMonth'] as num?)?.toInt() ?? 1,
      expiryYear: (json['expiryYear'] as num?)?.toInt() ?? DateTime.now().year + 1,
      isDefault: json['isDefault'] == true,
    );
  }
}

class PaymentMethodsProvider with ChangeNotifier {
  static const String _storageKey = 'mock_payment_methods';

  final List<PaymentMethod> _methods = <PaymentMethod>[];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<PaymentMethod> get methods => List<PaymentMethod>.unmodifiable(_methods);

  PaymentMethodsProvider() {
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      _methods
        ..clear()
        ..addAll(_seedMethods());
      await _save();
    } else {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is! List) {
          throw const FormatException('Payment methods cache is not a list.');
        }

        _methods
          ..clear()
          ..addAll(
            decoded
                .whereType<Map>()
                .map((item) => Map<String, dynamic>.from(item))
                .map(PaymentMethod.fromJson)
                .where((method) => method.id.isNotEmpty),
          );

        if (_methods.isEmpty) {
          _methods.addAll(_seedMethods());
        }
        _ensureSingleDefault();
      } catch (_) {
        _methods
          ..clear()
          ..addAll(_seedMethods());
        await _save();
      }
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> addMockMethod() async {
    final brands = <String>['Visa', 'Mastercard', 'Amex'];
    final now = DateTime.now().millisecondsSinceEpoch;
    final brand = brands[now % brands.length];
    final nextDigit = ((now ~/ 7) % 10000).toString().padLeft(4, '0');
    final expiryMonth = ((now % 12) + 1).toInt();
    final expiryYear = DateTime.now().year + ((now % 4) + 2).toInt();

    _methods.add(
      PaymentMethod(
        id: 'pm_$now',
        brand: brand,
        last4: nextDigit,
        holderName: 'Explore Traveler',
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: _methods.isEmpty,
      ),
    );

    _ensureSingleDefault();
    await _save();
    notifyListeners();
  }

  Future<void> removeMethod(String id) async {
    final removedDefault = _methods.any((method) => method.id == id && method.isDefault);
    _methods.removeWhere((method) => method.id == id);

    if (removedDefault && _methods.isNotEmpty) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
    }

    _ensureSingleDefault();
    await _save();
    notifyListeners();
  }

  Future<void> setDefault(String id) async {
    for (var i = 0; i < _methods.length; i++) {
      final method = _methods[i];
      _methods[i] = method.copyWith(isDefault: method.id == id);
    }

    _ensureSingleDefault();
    await _save();
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final payload = _methods.map((method) => method.toJson()).toList(growable: false);
    await prefs.setString(_storageKey, jsonEncode(payload));
  }

  void _ensureSingleDefault() {
    if (_methods.isEmpty) {
      return;
    }

    final defaultIndex = _methods.indexWhere((method) => method.isDefault);
    if (defaultIndex == -1) {
      _methods[0] = _methods[0].copyWith(isDefault: true);
      return;
    }

    for (var i = 0; i < _methods.length; i++) {
      if (i != defaultIndex && _methods[i].isDefault) {
        _methods[i] = _methods[i].copyWith(isDefault: false);
      }
    }
  }

  List<PaymentMethod> _seedMethods() {
    final year = DateTime.now().year;
    return <PaymentMethod>[
      PaymentMethod(
        id: 'pm_seed_visa',
        brand: 'Visa',
        last4: '4242',
        holderName: 'Explore Traveler',
        expiryMonth: 12,
        expiryYear: year + 2,
        isDefault: true,
      ),
      PaymentMethod(
        id: 'pm_seed_master',
        brand: 'Mastercard',
        last4: '8888',
        holderName: 'Explore Traveler',
        expiryMonth: 8,
        expiryYear: year + 3,
      ),
    ];
  }
}
