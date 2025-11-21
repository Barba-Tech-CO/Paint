import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';

import '../config/app_config.dart';
import '../utils/logger/app_logger.dart';
import 'auth_persistence_service.dart';
import 'i_http_service.dart';

class HttpService implements IHttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;
  late final AppLogger _logger;
  String? _authToken;
  late final AuthPersistenceService _authPersistenceService;
  final FirebasePerformance _performance = FirebasePerformance.instance;

  // Callback for handling authentication failures
  void Function()? _onAuthFailure;

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
        },
      ),
    );

    // Add interceptor to include auth token in all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from memory first, then from storage if not available
          String? token = _authToken;

          if (token == null) {
            token = await _authPersistenceService.getSanctumToken();
            if (token != null) {
              _authToken = token;
            }
          }

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            _logger.warning(
              '[HttpService] No auth token available for ${options.path}',
            );
            // Log missing token for critical endpoints
            if (options.path.contains('/user')) {
              _logger.warning(
                '[HttpService] No auth token available for /user request',
              );
            } else if (options.path.contains('/materials')) {
              _logger.warning(
                '[HttpService] No auth token available for /materials request',
              );
            } else if (options.path.contains('/contacts')) {
              _logger.warning(
                '[HttpService] No auth token available for /contacts request',
              );
            } else if (options.path.contains('/estimates')) {
              _logger.warning(
                '[HttpService] No auth token available for /estimates request',
              );
            }
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors - token expired
          if (error.response?.statusCode == 401) {
            _logger.warning(
              '[HttpService] 401 Unauthorized - Token expired for ${error.requestOptions.path}',
            );

            // Clear expired token
            _authToken = null;
            await _authPersistenceService.clearAuthState();

            // Trigger auth failure callback
            try {
              if (_onAuthFailure != null) {
                _onAuthFailure!();
              } else {
                _logger.warning('[HttpService] Auth failure callback is null');
              }
            } catch (e) {
              _logger.warning(
                '[HttpService] Error in auth failure callback: $e',
              );
            }
          }
          handler.next(error);
        },
      ),
    );

    // Add Firebase Performance interceptor for HTTP metrics
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final httpMetric = _performance.newHttpMetric(
            options.uri.toString(),
            _mapHttpMethod(options.method),
          );

          options.extra['firebase_performance_metric'] = httpMetric;
          await httpMetric.start();
          handler.next(options);
        },
        onResponse: (response, handler) async {
          final httpMetric =
              response.requestOptions.extra['firebase_performance_metric']
                  as HttpMetric?;

          if (httpMetric != null) {
            httpMetric.httpResponseCode = response.statusCode;
            httpMetric.responseContentType = response.headers['content-type']?.first;
            httpMetric.responsePayloadSize =
                response.data?.toString().length ?? 0;
            await httpMetric.stop();
          }

          handler.next(response);
        },
        onError: (error, handler) async {
          final httpMetric = error.requestOptions.extra['firebase_performance_metric']
              as HttpMetric?;

          if (httpMetric != null) {
            httpMetric.httpResponseCode = error.response?.statusCode;
            await httpMetric.stop();
          }

          handler.next(error);
        },
      ),
    );
  }

  HttpMethod _mapHttpMethod(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return HttpMethod.Get;
      case 'POST':
        return HttpMethod.Post;
      case 'PUT':
        return HttpMethod.Put;
      case 'DELETE':
        return HttpMethod.Delete;
      case 'PATCH':
        return HttpMethod.Patch;
      case 'HEAD':
        return HttpMethod.Head;
      case 'OPTIONS':
        return HttpMethod.Options;
      default:
        return HttpMethod.Get;
    }
  }

  void setLogger(AppLogger logger) {
    _logger = logger;
  }

  /// Sets the auth token for API authentication
  @override
  void setGhlToken(String token) {
    _authToken = token;
  }

  /// Gets the current auth token
  @override
  String? get ghlToken => _authToken;

  /// Clears the auth token
  @override
  void clearGhlToken() {
    _authToken = null;
  }

  /// Sets the auth token and forces interceptor refresh
  void setAuthToken(String token) {
    _authToken = token;
  }

  /// Clears auth token from memory
  void clearAuthToken() {
    _authToken = null;
  }

  /// Initialize auth token from persistence during app startup
  Future<void> initializeAuthToken() async {
    try {
      final token = await _authPersistenceService.getSanctumToken();

      if (token != null && token.isNotEmpty) {
        _authToken = token;
      } else {
        _logger.warning('[HttpService] No auth token found in persistence');
      }
    } catch (e) {
      _logger.error('[HttpService] Error initializing auth token: $e');
    }
  }

  /// Set callback to handle authentication failures
  void setAuthFailureCallback(void Function() callback) {
    _onAuthFailure = callback;
  }

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      // Only log errors and important status codes
      if (response.statusCode != 200) {}

      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: GET $path', e, e.stackTrace);
      return _handleDioException(e, path);
    }
  }

  /// Handles DioException and returns a proper Response
  Response _handleDioException(DioException e, String path) {
    // Create a mock response with error details
    return Response(
      requestOptions: RequestOptions(path: path),
      statusCode: e.response?.statusCode ?? 500,
      statusMessage: e.message,
      data: {'error': e.message},
    );
  }

  @override
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != 200) {}
      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: POST $path', e, e.stackTrace);
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
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != 200) {}
      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: PUT $path', e, e.stackTrace);
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
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != 200) {}
      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: PATCH $path', e, e.stackTrace);
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
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.statusCode != 200) {}
      return response;
    } on DioException catch (e) {
      _logger.error('HttpService Error: DELETE $path', e, e.stackTrace);
      rethrow;
    }
  }
}
