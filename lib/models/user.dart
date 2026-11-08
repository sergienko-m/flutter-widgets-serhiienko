import 'package:flutter/foundation.dart';

/// Незмінна модель користувача.
@immutable
class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  static final RegExp _emailRegExp = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String value) => _emailRegExp.hasMatch(value.trim());

  static bool isValidName(String value) => value.trim().length >= 2;

  /// Ініціали для аватара-заглушки: "Олександр Шевченко" -> "ОШ".
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  User copyWith({String? name, String? email, String? avatarUrl}) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          other.id == id &&
          other.name == name &&
          other.email == email &&
          other.avatarUrl == avatarUrl;

  @override
  int get hashCode => Object.hash(id, name, email, avatarUrl);
}
