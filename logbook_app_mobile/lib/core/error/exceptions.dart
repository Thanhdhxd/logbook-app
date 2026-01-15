// lib/core/error/exceptions.dart

/// Base exception cho tất cả custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException(this.message, {this.code, this.originalError});

  @override
  String toString() => message;
}

/// Exception khi có lỗi network (timeout, no internet, etc.)
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.originalError});

  factory NetworkException.timeout() {
    return const NetworkException(
      'Kết nối quá chậm. Vui lòng thử lại.',
      code: 'NETWORK_TIMEOUT',
    );
  }

  factory NetworkException.noInternet() {
    return const NetworkException(
      'Không có kết nối Internet. Vui lòng kiểm tra lại.',
      code: 'NO_INTERNET',
    );
  }

  factory NetworkException.connectionFailed() {
    return const NetworkException(
      'Không thể kết nối đến server. Vui lòng thử lại sau.',
      code: 'CONNECTION_FAILED',
    );
  }
}

/// Exception liên quan đến authentication
class AuthException extends AppException {
  final int? statusCode;

  const AuthException(
    super.message, {
    super.code,
    this.statusCode,
    super.originalError,
  });

  factory AuthException.unauthorized() {
    return const AuthException(
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
      code: 'UNAUTHORIZED',
      statusCode: 401,
    );
  }

  factory AuthException.invalidCredentials() {
    return const AuthException(
      'Email hoặc mật khẩu không đúng.',
      code: 'INVALID_CREDENTIALS',
      statusCode: 401,
    );
  }

  factory AuthException.forbidden() {
    return const AuthException(
      'Bạn không có quyền thực hiện thao tác này.',
      code: 'FORBIDDEN',
      statusCode: 403,
    );
  }
}

/// Exception khi validate dữ liệu
class ValidationException extends AppException {
  final Map<String, String>? errors;

  const ValidationException(
    super.message, {
    super.code,
    this.errors,
    super.originalError,
  });

  factory ValidationException.required(String fieldName) {
    return ValidationException(
      'Vui lòng nhập $fieldName.',
      code: 'REQUIRED_FIELD',
      errors: {fieldName: 'Trường này là bắt buộc'},
    );
  }

  factory ValidationException.invalidFormat(String fieldName) {
    return ValidationException(
      '$fieldName không đúng định dạng.',
      code: 'INVALID_FORMAT',
      errors: {fieldName: 'Định dạng không hợp lệ'},
    );
  }
}

/// Exception từ server (4xx, 5xx errors)
class ServerException extends AppException {
  final int statusCode;

  const ServerException(
    super.message, {
    required this.statusCode,
    super.code,
    super.originalError,
  });

  factory ServerException.badRequest([String? message]) {
    return ServerException(
      message ?? 'Yêu cầu không hợp lệ.',
      statusCode: 400,
      code: 'BAD_REQUEST',
    );
  }

  factory ServerException.notFound([String? resource]) {
    return ServerException(
      resource != null ? '$resource không tồn tại.' : 'Không tìm thấy dữ liệu.',
      statusCode: 404,
      code: 'NOT_FOUND',
    );
  }

  factory ServerException.internalError() {
    return const ServerException(
      'Lỗi server. Vui lòng thử lại sau.',
      statusCode: 500,
      code: 'INTERNAL_SERVER_ERROR',
    );
  }

  factory ServerException.serviceUnavailable() {
    return const ServerException(
      'Dịch vụ tạm thời không khả dụng. Vui lòng thử lại sau.',
      statusCode: 503,
      code: 'SERVICE_UNAVAILABLE',
    );
  }
}

/// Exception khi parse JSON/data
class ParseException extends AppException {
  const ParseException(super.message, {super.code, super.originalError});

  factory ParseException.invalidJson() {
    return const ParseException(
      'Dữ liệu trả về không hợp lệ.',
      code: 'INVALID_JSON',
    );
  }
}

/// Exception chung cho các lỗi không xác định
class UnknownException extends AppException {
  const UnknownException([String? message, dynamic error])
      : super(
          message ?? 'Đã có lỗi xảy ra. Vui lòng thử lại.',
          code: 'UNKNOWN_ERROR',
          originalError: error,
        );
}
