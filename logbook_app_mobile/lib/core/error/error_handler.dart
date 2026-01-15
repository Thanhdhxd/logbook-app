// lib/core/error/error_handler.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'exceptions.dart';
import '../network/app_logger.dart';

/// Utility class để convert Dio errors thành custom exceptions
class ErrorHandler {
  static final _logger = AppLogger.instance;

  /// Convert DioException thành custom AppException
  static AppException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is SocketException) {
      return NetworkException.noInternet();
    } else if (error is AppException) {
      return error;
    } else {
      _logger.error('Unknown error occurred', error);
      return UnknownException(error?.toString(), error);
    }
  }

  static AppException _handleDioError(DioException error) {
    _logger.error(
      'DioError [${error.type}]: ${error.message}',
      error,
      error.stackTrace,
    );

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException.timeout();

      case DioExceptionType.badResponse:
        return _handleResponseError(error);

      case DioExceptionType.cancel:
        return const NetworkException(
          'Yêu cầu đã bị hủy.',
          code: 'REQUEST_CANCELLED',
        );

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        if (error.error is SocketException) {
          return NetworkException.noInternet();
        }
        return NetworkException.connectionFailed();

      case DioExceptionType.badCertificate:
        return const NetworkException(
          'Chứng chỉ bảo mật không hợp lệ.',
          code: 'BAD_CERTIFICATE',
        );
    }
  }

  static AppException _handleResponseError(DioException error) {
    final statusCode = error.response?.statusCode ?? 0;
    final data = error.response?.data;

    // Lấy message từ backend nếu có
    String? serverMessage;
    if (data is Map<String, dynamic>) {
      serverMessage = data['message'] as String?;
    }

    switch (statusCode) {
      case 400:
        return ServerException.badRequest(serverMessage);

      case 401:
        return serverMessage != null
            ? AuthException(serverMessage, statusCode: 401)
            : AuthException.unauthorized();

      case 403:
        return AuthException.forbidden();

      case 404:
        return ServerException.notFound(serverMessage);

      case 422:
        // Validation error từ backend
        Map<String, String>? validationErrors;
        if (data is Map<String, dynamic> && data['errors'] != null) {
          validationErrors = Map<String, String>.from(data['errors']);
        }
        return ValidationException(
          serverMessage ?? 'Dữ liệu không hợp lệ.',
          code: 'VALIDATION_ERROR',
          errors: validationErrors,
        );

      case 500:
        return ServerException.internalError();

      case 503:
        return ServerException.serviceUnavailable();

      default:
        return ServerException(
          serverMessage ?? 'Lỗi server (HTTP $statusCode).',
          statusCode: statusCode,
          code: 'HTTP_ERROR',
        );
    }
  }

  /// Helper để lấy user-friendly message từ exception
  static String getErrorMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }
    return 'Đã có lỗi xảy ra. Vui lòng thử lại.';
  }
}
