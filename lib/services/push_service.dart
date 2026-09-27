import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../repositories/travel_repository.dart';

/// Trip notifications (booking confirmed, reminder the day before).
///
/// Registers this device with the backend once the traveller is signed in,
/// and shows notifications received while the app is open.
class PushService {
  final TravelRepository _repository;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  String? _token;
  StreamSubscription<String>? _tokenRefresh;
  StreamSubscription<RemoteMessage>? _foreground;

  PushService(this._repository, {required this.messengerKey});

  Future<void> enable() async {
    if (kIsWeb) return;
    try {
      final messaging = FirebaseMessaging.instance;
      final permission = await messaging.requestPermission();
      if (permission.authorizationStatus == AuthorizationStatus.denied) return;
      _token = await messaging.getToken();
      if (_token != null) await _register(_token!);
      _tokenRefresh ??= messaging.onTokenRefresh.listen((token) {
        _token = token;
        _register(token);
      });
      _foreground ??= FirebaseMessaging.onMessage.listen(_showInApp);
    } catch (e) {
      // Push is a convenience: never block the app on it.
      if (kDebugMode) debugPrint('[Push] not available: $e');
    }
  }

  /// Call before signing out, while the session can still unregister.
  Future<void> disable() async {
    final token = _token;
    _token = null;
    await _tokenRefresh?.cancel();
    _tokenRefresh = null;
    if (token == null) return;
    try {
      await _repository.unregisterDevice(token);
    } catch (_) {}
  }

  Future<void> _register(String token) async {
    try {
      await _repository.registerDevice(
          token, defaultTargetPlatform.name.toLowerCase());
    } catch (e) {
      if (kDebugMode) debugPrint('[Push] registration failed: $e');
    }
  }

  void _showInApp(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;
    messengerKey.currentState?.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text([notification.title, notification.body]
          .whereType<String>()
          .join('\n')),
    ));
  }
}
