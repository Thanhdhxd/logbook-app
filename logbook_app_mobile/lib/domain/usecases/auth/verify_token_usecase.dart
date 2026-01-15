// lib/domain/usecases/auth/verify_token_usecase.dart

import '../../repositories/i_auth_repository.dart';

/// Use Case - Verify Token
/// Single Responsibility: Verify authentication token validity
class VerifyTokenUseCase {
  final IAuthRepository _repository;

  VerifyTokenUseCase(this._repository);

  /// Execute token verification
  /// Returns true if token is valid and user is authenticated
  Future<bool> execute() async {
    return await _repository.verifyToken();
  }
}
