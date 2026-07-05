import '../../models/user_model.dart';

class AuthUserDto {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? provider;
  final DateTime? createdAt;

  const AuthUserDto({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.provider,
    this.createdAt,
  });

  factory AuthUserDto.fromJson(Map<String, dynamic> json) {
    return AuthUserDto(
      uid: (json['uid'] ?? '').toString(),
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      provider: json['provider'] as String?,
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }

  AppUser toDomain() {
    return AppUser(
      uid: uid,
      email: email,
      displayName: displayName,
      photoURL: photoURL,
      provider: provider,
      createdAt: createdAt,
    );
  }
}
