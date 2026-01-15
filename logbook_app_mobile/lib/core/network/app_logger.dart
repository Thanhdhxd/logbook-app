// lib/core/network/app_logger.dart

import 'package:logger/logger.dart';
import '../../config/environment.dart';

/// Singleton logger cho toàn app
class AppLogger {
  static final AppLogger _instance = AppLogger._internal();
  static AppLogger get instance => _instance;

  late final Logger _logger;

  AppLogger._internal() {
    _logger = Logger(
      filter: _CustomLogFilter(),
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
      output: ConsoleOutput(),
    );
  }

  /// Log debug message
  void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    if (Environment.isDebugMode) {
      _logger.d(message, error: error, stackTrace: stackTrace);
    }
  }

  /// Log info message
  void info(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// Log warning message
  void warning(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// Log error message
  void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// Log API request
  void logRequest(String method, String url, dynamic data) {
    if (Environment.isDebugMode) {
      _logger.d('🌐 API Request [$method] $url\nData: $data');
    }
  }

  /// Log API response
  void logResponse(String method, String url, int statusCode, dynamic data) {
    if (Environment.isDebugMode) {
      final emoji = statusCode >= 200 && statusCode < 300 ? '✅' : '❌';
      _logger.d('$emoji API Response [$method] $url\nStatus: $statusCode\nData: $data');
    }
  }

  /// Log API error
  void logApiError(String method, String url, dynamic error) {
    _logger.e('❌ API Error [$method] $url', error: error);
  }
}

/// Custom filter để chỉ log khi ở debug mode
class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Production: chỉ log warning và error
    if (Environment.isProduction) {
      return event.level.index >= Level.warning.index;
    }
    // Development/Staging: log tất cả
    return true;
  }
}
