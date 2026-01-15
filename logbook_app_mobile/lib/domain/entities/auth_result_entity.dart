// lib/domain/entities/auth_result_entity.dart

import 'user_entity.dart';

/// Domain Entity - Authentication Result
class AuthResultEntity {
  final bool success;
  final String message;
  final UserEntity? user;

  const AuthResultEntity({
    required this.success,
    required this.message,
    this.user,
  });

  @override
  String toString() => 'AuthResultEntity(success: $success, message: $message, user: $user)';
}
