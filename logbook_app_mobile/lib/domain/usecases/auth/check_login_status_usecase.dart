// lib/domain/usecases/auth/check_login_status_usecase.dart

import '../../repositories/i_auth_repository.dart';

/// Use Case - Check Login Status
/// Single Responsibility: Check if user is currently logged in
class CheckLoginStatusUseCase {
  final IAuthRepository _repository;

  CheckLoginStatusUseCase(this._repository);

  /// Execute login status check
  /// Returns true if user has valid session
  Future<bool> execute() async {
    return await _repository.isLoggedIn();
  }
}
