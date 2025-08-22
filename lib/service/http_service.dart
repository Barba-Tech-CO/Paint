import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

import '../config/app_config.dart';
import '../utils/logger/app_logger.dart';
import 'auth_persistence_service.dart';
import 'auth_service_exception.dart';
import 'i_http_service.dart';

class HttpService implements IHttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;
  late final AppLogger _logger;
  late final AuthPersistenceService _authPersistenceService;

  factory HttpService() {
    return _instance;
  }

  HttpService._internal() {
    _authPersistenceService = AuthPersistenceService();

    dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          // Add desktop browser headers to ensure consistent backend behavior
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept-Language': 'en-US,en;q=0.9',
          'Accept-Encoding': 'gzip, deflate, br',
          'DNT': '1',
          'Connection': 'keep-alive',
          'Upgrade-Insecure-Requests': '1',
        },
      ),
    );

    // Force disable proxy and use direct connection
    (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.findProxy = (uri) {
        // Force direct connection, no proxy
        return 'DIRECT';
      };
      return client;
    };

    // Add cookie support for session-based authentication
    final cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));

    // Add interceptor to automatically include Sanctum token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Log request details for debugging
          _logger.info('🌐 HTTP Request: ${options.method} ${options.path}');
          _logger.info('🌐 Base URL: ${dio.options.baseUrl}');
          _logger.info('🌐 Full URL: ${dio.options.baseUrl}${options.path}');
          _logger.info('🌐 Request headers: ${options.headers}');

          // Add authorization header for protected endpoints
          if (_requiresAuth(options.path)) {
            final token = await _authPersistenceService.getSanctumToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
              _logger.info(
                '✅ Added auth token to ${options.path}: $token',
              );
            } else {
              _logger.warning(
                '❌ No auth token available for protected endpoint: ${options.path}',
              );
              _logger.info(
                'Attempting request without Bearer token (may use session-based auth)',
              );
            }
          } else {
            _logger.info('Public endpoint, no auth required: ${options.path}');
          }
          handler.next(options);
        },
      ),
    );
  }

  void setLogger(AppLogger logger) {
    _logger = logger;
  }

  /// Determines if the endpoint requires authentication
  bool _requiresAuth(String path) {
    // Endpoints that don't require authentication (public)
    final publicEndpoints = [
      'auth/status',
      'auth/callback',
      'auth/redirect',
      'auth/refresh',
      'auth/success',
      'health',
    ];

    // Check if it's explicitly public
    if (publicEndpoints.any((endpoint) => path.contains(endpoint))) {
      return false;
    }

    // All other API endpoints require authentication by default
    // This includes: /api/user, /api/contacts, /api/estimates, etc.
    // Also include /user endpoint specifically
    return path.startsWith('api/') || path.startsWith('/api/') || path == '/user' || path == 'user';
  }

  /// Determines if the endpoint is an authentication-related endpoint
  bool _isAuthEndpoint(String path) {
    final authEndpoints = [
      '/auth/callback',
      '/api/user',
      'auth/callback',
      'api/user',
    ];

    return authEndpoints.any((endpoint) => path.contains(endpoint));
  }

  /// Handles DioException and converts HTTP 500 on auth endpoints to AuthServiceException
  Never _handleDioException(DioException e, String path) {
    if (e.response?.statusCode == 500 && _isAuthEndpoint(path)) {
      _logger.error(
        'HTTP 500 error on auth endpoint: $path',
        e,
        e.stackTrace,
      );

      throw AuthServiceException(
        message:
            'Authentication service is temporarily unavailable. Please try again in a few moments.',
        errorType: AuthServiceErrorType.serviceUnavailable,
        technicalDetails: 'HTTP 500 on $path: ${e.message}',
      );
    }

    // For non-auth endpoints or other status codes, rethrow original exception
    throw e;
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final startTime = DateTime.now();
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      final duration = DateTime.now().difference(startTime);

      _logger.info('API Call: GET $path - Status: ${response.statusCode}');
      if (queryParameters != null) {
        _logger.info('Request Data: $queryParameters');
      }
      _logger.info('Response JSON: ${response.data}');
      _logger.info(
        'Performance: HTTP GET $path took ${duration.inMilliseconds}ms',
      );

      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: GET $path', e, e.stackTrace);
      _handleDioException(e, path);
    }
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = '${dio.options.baseUrl}$path';

    _logger.info('--> POST $fullPath');

    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      _logger.info('<-- ${response.statusCode} POST $fullPath');
      _logger.info('POST Response JSON: ${response.data}');
      return response;
    } on DioException catch (e) {
      _logger.error(
        '<-- ${e.response?.statusCode ?? 'ERROR'} POST $fullPath: $e',
      );
      rethrow;
    }
  }

  @override
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = '${dio.options.baseUrl}$path';

    _logger.info('--> PUT $fullPath');

    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      _logger.info('<-- ${response.statusCode} PUT $fullPath');
      return response;
    } on DioException catch (e) {
      _logger.error(
        '<-- ${e.response?.statusCode ?? 'ERROR'} PUT $fullPath: $e',
      );
      rethrow;
    }
  }

  @override
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = '${dio.options.baseUrl}$path';

    _logger.info('--> PATCH $fullPath');

    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      _logger.info('<-- ${response.statusCode} PATCH $fullPath');
      return response;
    } on DioException catch (e) {
      _logger.error(
        '<-- ${e.response?.statusCode ?? 'ERROR'} PATCH $fullPath: $e',
      );
      rethrow;
    }
  }

  @override
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = '${dio.options.baseUrl}$path';

    _logger.info('--> DELETE $fullPath');

    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      _logger.info('<-- ${response.statusCode} DELETE $fullPath');
      return response;
    } on DioException catch (e) {
      _logger.error(
        '<-- ${e.response?.statusCode ?? 'ERROR'} DELETE $fullPath: $e',
      );
      rethrow;
    }
  }
}
