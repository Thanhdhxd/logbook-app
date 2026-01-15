// lib/domain/usecases/auth/logout_usecase.dart

import '../../repositories/i_auth_repository.dart';

/// Use Case - Logout
/// Single Responsibility: Handle user logout
class LogoutUseCase {
  final IAuthRepository _repository;

  LogoutUseCase(this._repository);

  /// Execute logout
  /// Clears all user session data
  Future<void> execute() async {
    await _repository.logout();
  }
}
