// lib/config/environment.dart

/// Enum cho các môi trường deployment
enum EnvironmentType {
  development,
  staging,
  production,
}

/// Configuration cho từng môi trường
class Environment {
  // Môi trường hiện tại - THAY ĐỔI TẠI ĐÂY
  static const EnvironmentType current = EnvironmentType.development;

  // API URLs cho từng môi trường
  static const Map<EnvironmentType, String> _apiUrls = {
    EnvironmentType.development: 'http://localhost:3000/api',
    EnvironmentType.staging: 'https://staging-logbook-backend.onrender.com/api',
    EnvironmentType.production: 'https://logbook-backend-pxuq.onrender.com/api',
  };

  // Timeout settings
  static const Map<EnvironmentType, int> _timeouts = {
    EnvironmentType.development: 30000, // 30s cho dev (có thể debug lâu)
    EnvironmentType.staging: 20000,     // 20s cho staging
    EnvironmentType.production: 15000,  // 15s cho production
  };

  // Logging levels
  static const Map<EnvironmentType, bool> _enableDebugLog = {
    EnvironmentType.development: true,
    EnvironmentType.staging: true,
    EnvironmentType.production: false, // Tắt debug log trên production
  };

  /// Lấy base URL của API theo môi trường hiện tại
  static String get apiUrl => _apiUrls[current]!;

  /// Lấy timeout (milliseconds)
  static int get timeout => _timeouts[current]!;

  /// Check xem có enable debug logging không
  static bool get isDebugMode => _enableDebugLog[current]!;

  /// Check môi trường
  static bool get isDevelopment => current == EnvironmentType.development;
  static bool get isStaging => current == EnvironmentType.staging;
  static bool get isProduction => current == EnvironmentType.production;

  /// Thông tin môi trường (để debug)
  static String get environmentName {
    switch (current) {
      case EnvironmentType.development:
        return 'Development';
      case EnvironmentType.staging:
        return 'Staging';
      case EnvironmentType.production:
        return 'Production';
    }
  }

  /// In thông tin môi trường (gọi khi app start)
  static void printInfo() {
    print('=================================');
    print('Environment: $environmentName');
    print('API URL: $apiUrl');
    print('Timeout: ${timeout}ms');
    print('Debug Mode: $isDebugMode');
    print('=================================');
  }
}
