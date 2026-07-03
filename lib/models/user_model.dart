// models/user_model.dart
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? provider;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.provider,
    this.createdAt,
  });

  factory AppUser.fromFirebase(User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      provider: user.providerData.isNotEmpty ? user.providerData[0].providerId : null,
      createdAt: user.metadata.creationTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'provider': provider,
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}