// lib/data/repositories/auth_repository_impl.dart

import '../../domain/entities/auth_result_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/i_auth_repository.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/error_handler.dart';
import '../datasources/auth_remote_datasource.dart';
import '../../data/models/user_dto.dart';

/// Implementation of IAuthRepository
/// Implements the contract defined in domain layer
class AuthRepositoryImpl implements IAuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final _logger = AppLogger.instance;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<AuthResultEntity> login(String username, String password) async {
    try {
      final response = await _remoteDataSource.login(
        username: username,
        password: password,
      );

      if (response['success'] == true) {
        final userJson = response['data']['user'] as Map<String, dynamic>;
        final userDTO = UserDTO.fromJson(userJson);
        final userEntity = userDTO.toEntity();

        return AuthResultEntity(
          success: true,
          message: response['message'] as String? ?? 'Đăng nhập thành công',
          user: userEntity,
        );
      } else {
        return AuthResultEntity(
          success: false,
          message: response['message'] as String? ?? 'Đăng nhập thất bại',
        );
      }
    } catch (e) {
      _logger.error('AuthRepository: Login failed', e);
      return AuthResultEntity(
        success: false,
        message: ErrorHandler.getErrorMessage(e),
      );
    }
  }

  @override
  Future<bool> verifyToken() async {
    try {
      return await _remoteDataSource.verifyToken();
    } catch (e) {
      _logger.warning('AuthRepository: Token verification failed', e);
      return false;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
      _logger.info('AuthRepository: User logged out');
    } catch (e) {
      _logger.error('AuthRepository: Logout failed', e);
      rethrow;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      return await _remoteDataSource.isLoggedIn();
    } catch (e) {
      _logger.error('AuthRepository: Check login status failed', e);
      return false;
    }
  }
}
