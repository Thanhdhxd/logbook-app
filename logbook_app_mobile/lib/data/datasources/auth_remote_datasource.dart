// lib/data/datasources/auth_remote_datasource.dart

import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../data/models/user_dto.dart';

/// Remote Data Source for Authentication
/// Handles all API calls related to authentication
class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;
  final _logger = AppLogger.instance;

  AuthRemoteDataSource({
    required ApiClient apiClient,
    required SecureStorageService secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage;

  /// Login via API
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    _logger.info('AuthRemoteDataSource: Attempting login for $username');

    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'username': username,
        'password': password,
      },
    );

    if (response['success'] == true) {
      // Save token and user info
      final token = response['data']['token'] as String;
      final userJson = response['data']['user'] as Map<String, dynamic>;
      final userDTO = UserDTO.fromJson(userJson);

      await _secureStorage.saveToken(token);
      await _secureStorage.saveUserInfo(
        userId: userDTO.id,
        userName: userDTO.name,
        userUsername: userDTO.username,
      );

      _logger.info('AuthRemoteDataSource: Login successful for ${userDTO.name}');
    }

    return response;
  }

  /// Verify token via API
  Future<bool> verifyToken() async {
    try {
      final response = await _apiClient.post('/auth/verify');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('AuthRemoteDataSource: Token verification failed', e);
      return false;
    }
  }

  /// Logout (clear local storage)
  Future<void> logout() async {
    _logger.info('AuthRemoteDataSource: Logging out user');
    await _secureStorage.clearAll();
  }

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    return await _secureStorage.isLoggedIn();
  }
}
