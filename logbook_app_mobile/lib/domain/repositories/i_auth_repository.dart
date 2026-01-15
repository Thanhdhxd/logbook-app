// lib/domain/repositories/i_auth_repository.dart

import '../entities/auth_result_entity.dart';

/// Repository Interface for Authentication
/// Defines the contract for authentication operations
/// Implementation will be in data layer
abstract class IAuthRepository {
  /// Login with username and password
  Future<AuthResultEntity> login(String username, String password);

  /// Verify if current token is valid
  Future<bool> verifyToken();

  /// Logout and clear session
  Future<void> logout();

  /// Check if user is currently logged in
  Future<bool> isLoggedIn();
}
