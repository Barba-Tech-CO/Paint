import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/logger/app_logger.dart';
import 'auth_persistence_service.dart';
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
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );
    
    // Add interceptor to automatically include Sanctum token
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header for protected endpoints
          if (_requiresAuth(options.path)) {
            final token = await _authPersistenceService.getSanctumToken();
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
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
    // Endpoints that require Sanctum authentication
    final protectedEndpoints = [
      'api/user',
      'contacts/',
      'estimates/',
    ];
    
    // Endpoints that don't require authentication
    final publicEndpoints = [
      'auth/status',
      'auth/callback',
      'auth/redirect',
      'auth/refresh',
      'health',
    ];
    
    // Check if it's explicitly public
    if (publicEndpoints.any((endpoint) => path.contains(endpoint))) {
      return false;
    }
    
    // Check if it's a protected endpoint
    return protectedEndpoints.any((endpoint) => path.contains(endpoint));
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
      _logger.info('Response Data: ${response.data}');
      _logger.info(
        'Performance: HTTP GET $path took ${duration.inMilliseconds}ms',
      );

      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: GET $path', e, e.stackTrace);
      rethrow;
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
