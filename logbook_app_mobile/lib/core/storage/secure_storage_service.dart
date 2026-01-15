// lib/core/storage/secure_storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../network/app_logger.dart';

/// Service for securely storing sensitive data like tokens
/// Uses platform-specific secure storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences
/// - Web: Web Crypto API
/// - Desktop: libsecret (Linux), Credential Manager (Windows), Keychain (macOS)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  static SecureStorageService get instance => _instance;

  final _logger = AppLogger.instance;
  
  // FlutterSecureStorage instance with options
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    webOptions: WebOptions(
      dbName: 'logbook_secure_storage',
      publicKey: 'logbook_public_key',
    ),
  );

  // Keys for secure storage
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userUsernameKey = 'user_username';

  // ==================== Token Management ====================

  /// Save authentication token securely
  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      _logger.debug('Token saved securely');
    } catch (e) {
      _logger.error('Failed to save token', e);
      rethrow;
    }
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      _logger.error('Failed to read token', e);
      return null;
    }
  }

  /// Save refresh token securely
  Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      _logger.debug('Refresh token saved securely');
    } catch (e) {
      _logger.error('Failed to save refresh token', e);
      rethrow;
    }
  }

  /// Get refresh token
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      _logger.error('Failed to read refresh token', e);
      return null;
    }
  }

  /// Delete authentication token
  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
      await _storage.delete(key: _refreshTokenKey);
      _logger.debug('Tokens deleted');
    } catch (e) {
      _logger.error('Failed to delete tokens', e);
    }
  }

  // ==================== User Info Management ====================

  /// Save user information securely
  Future<void> saveUserInfo({
    required String userId,
    required String userName,
    required String userUsername,
  }) async {
    try {
      await Future.wait([
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userNameKey, value: userName),
        _storage.write(key: _userUsernameKey, value: userUsername),
      ]);
      _logger.debug('User info saved securely');
    } catch (e) {
      _logger.error('Failed to save user info', e);
      rethrow;
    }
  }

  /// Get user information
  Future<Map<String, String?>> getUserInfo() async {
    try {
      final results = await Future.wait([
        _storage.read(key: _userIdKey),
        _storage.read(key: _userNameKey),
        _storage.read(key: _userUsernameKey),
      ]);

      return {
        'userId': results[0],
        'userName': results[1],
        'userUsername': results[2],
      };
    } catch (e) {
      _logger.error('Failed to read user info', e);
      return {
        'userId': null,
        'userName': null,
        'userUsername': null,
      };
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.error('Failed to read user ID', e);
      return null;
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      _logger.error('Failed to read user name', e);
      return null;
    }
  }

  /// Get user username
  Future<String?> getUserUsername() async {
    try {
      return await _storage.read(key: _userUsernameKey);
    } catch (e) {
      _logger.error('Failed to read user username', e);
      return null;
    }
  }

  // ==================== Utility Methods ====================

  /// Check if user is logged in (has valid token)
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.info('All secure storage cleared');
    } catch (e) {
      _logger.error('Failed to clear secure storage', e);
    }
  }

  /// Write custom secure data
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      _logger.error('Failed to write secure data for key: $key', e);
      rethrow;
    }
  }

  /// Read custom secure data
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      _logger.error('Failed to read secure data for key: $key', e);
      return null;
    }
  }

  /// Delete custom secure data
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      _logger.error('Failed to delete secure data for key: $key', e);
    }
  }

  /// Check if a key exists
  Future<bool> containsKey(String key) async {
    try {
      return await _storage.containsKey(key: key);
    } catch (e) {
      _logger.error('Failed to check key existence: $key', e);
      return false;
    }
  }

  /// Get all keys (for debugging only)
  Future<Map<String, String>> readAll() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      _logger.error('Failed to read all secure data', e);
      return {};
    }
  }
}
