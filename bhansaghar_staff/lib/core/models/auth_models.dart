import 'package:equatable/equatable.dart';

enum UserRole { waiter, kitchen, unknown }

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final bool isVerified;
  final bool profileCompleted;

  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.isVerified,
    required this.profileCompleted,
  });

  User copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    bool? isVerified,
    bool? profileCompleted,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    role,
    isVerified,
    profileCompleted,
  ];
}

class AuthResponse extends Equatable {
  final String accessToken;
  final String refreshToken;
  final User user;

  const AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken, user];
}
