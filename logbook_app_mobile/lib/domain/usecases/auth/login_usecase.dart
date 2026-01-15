// lib/domain/usecases/auth/login_usecase.dart

import '../../entities/auth_result_entity.dart';
import '../../repositories/i_auth_repository.dart';

/// Use Case - Login
/// Single Responsibility: Handle user login
class LoginUseCase {
  final IAuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute login
  /// Returns AuthResultEntity with success status and user info
  Future<AuthResultEntity> execute({
    required String username,
    required String password,
  }) async {
    // Business logic validation
    if (username.isEmpty || password.isEmpty) {
      return const AuthResultEntity(
        success: false,
        message: 'Tên tài khoản và mật khẩu không được để trống',
      );
    }

    // Delegate to repository
    return await _repository.login(username, password);
  }
}
