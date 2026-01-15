// lib/services/auth_service.dart
import '../../core/network/api_client.dart';
import '../../core/network/app_logger.dart';
import '../../core/error/error_handler.dart';
import '../../core/storage/secure_storage_service.dart';

class AuthService {
  final _apiClient = ApiClient.instance;
  final _logger = AppLogger.instance;
  final _secureStorage = SecureStorageService.instance;

  // Đăng nhập
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      _logger.info('Attempting login for username: $username');

      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response['success'] == true) {
        // Lưu token và thông tin user
        final token = response['data']['token'];
        final user = response['data']['user'];
        
        await _secureStorage.saveToken(token);
        await _secureStorage.saveUserInfo(
          userId: user['id'],
          userName: user['name'],
          userUsername: user['username'],
        );

        _logger.info('Login successful for user: ${user['name']}');

        return {
          'success': true,
          'message': response['message'] ?? 'Đăng nhập thành công',
          'user': user,
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Đăng nhập thất bại',
        };
      }
    } catch (e) {
      _logger.error('Login failed', e);
      return {
        'success': false,
        'message': ErrorHandler.getErrorMessage(e),
      };
    }
  }

  // Xác thực token
  Future<bool> verifyToken() async {
    try {
      final token = await _secureStorage.getToken();
      
      if (token == null || token.isEmpty) {
        return false;
      }

      final response = await _apiClient.post('/auth/verify');
      return response['success'] == true;
    } catch (e) {
      _logger.warning('Token verification failed', e);
      return false;
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    _logger.info('User logged out');
    await _secureStorage.clearAll();
  }
}
