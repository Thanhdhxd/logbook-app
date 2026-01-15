// lib/core/network/api_client.dart

import 'package:dio/dio.dart';
import '../../config/environment.dart';
import '../storage/secure_storage_service.dart';
import '../error/error_handler.dart';
import '../error/exceptions.dart';
import 'app_logger.dart';

/// API Client tập trung với Dio
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  static ApiClient get instance => _instance;

  late final Dio _dio;
  final _logger = AppLogger.instance;

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.apiUrl,
        connectTimeout: Duration(milliseconds: Environment.timeout),
        receiveTimeout: Duration(milliseconds: Environment.timeout),
        sendTimeout: Duration(milliseconds: Environment.timeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Cho phép tất cả status để tự xử lý error
          return status != null && status < 500;
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    if (Environment.isDebugMode) {
      _dio.interceptors.add(_LoggingInterceptor());
    }
  }

  /// Getter để access Dio instance (cho các trường hợp đặc biệt)
  Dio get dio => _dio;

  /// GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// PATCH request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Xử lý response chung
  Map<String, dynamic> _handleResponse(Response response) {
    final statusCode = response.statusCode ?? 0;

    // Success (2xx)
    if (statusCode >= 200 && statusCode < 300) {
      if (response.data is Map<String, dynamic>) {
        return response.data;
      }
      return {'data': response.data};
    }

    // Client errors (4xx)
    if (statusCode >= 400 && statusCode < 500) {
      final data = response.data;
      String? message;
      if (data is Map<String, dynamic>) {
        message = data['message'] as String?;
      }

      if (statusCode == 401) {
        throw AuthException.unauthorized();
      } else if (statusCode == 403) {
        throw AuthException.forbidden();
      } else if (statusCode == 404) {
        throw ServerException.notFound();
      }

      throw ServerException(
        message ?? 'Lỗi từ server (HTTP $statusCode)',
        statusCode: statusCode,
      );
    }

    // Server errors (5xx)
    throw ServerException.internalError();
  }
}

/// Interceptor để tự động thêm auth token
class _AuthInterceptor extends Interceptor {
  final _secureStorage = SecureStorageService.instance;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Lấy token từ secure storage
    final token = await _secureStorage.getToken();

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Nếu lỗi 401 (unauthorized), có thể tự động refresh token ở đây
    if (err.response?.statusCode == 401) {
      // TODO: Implement token refresh logic nếu cần
      // final refreshed = await _refreshToken();
      // if (refreshed) {
      //   return handler.resolve(await _retry(err.requestOptions));
      // }

      // Clear token và redirect to login sẽ được xử lý ở UI layer
    }

    handler.next(err);
  }
}

/// Interceptor để log requests/responses (chỉ ở dev mode)
class _LoggingInterceptor extends Interceptor {
  final _logger = AppLogger.instance;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.logRequest(
      options.method,
      options.uri.toString(),
      options.data,
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.logResponse(
      response.requestOptions.method,
      response.requestOptions.uri.toString(),
      response.statusCode ?? 0,
      response.data,
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.logApiError(
      err.requestOptions.method,
      err.requestOptions.uri.toString(),
      err,
    );
    handler.next(err);
  }
}
