import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  AuthUser({
    String? id,
    required this.email,
    required this.name,
    this.avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastLoginAt = lastLoginAt ?? DateTime.now();

  /// Creates a copy of this user but with the given fields replaced with new values
  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Converts the user to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt.toIso8601String(),
    };
  }

  /// Creates a user from a JSON map
  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  /// Creates an empty user
  static final empty = AuthUser(
    id: '0',
    email: '',
    name: 'Guest',
  );

  /// Returns whether the current user is empty
  bool get isEmpty => this == AuthUser.empty;

  /// Returns whether the current user is not empty
  bool get isNotEmpty => this != AuthUser.empty;

  @override
  List<Object?> get props => [
        id,
        email,
        name,
        avatarUrl,
        createdAt,
        lastLoginAt,
      ];
}