import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/logger/app_logger.dart';
import 'i_http_service.dart';

class HttpService implements IHttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;
  late final AppLogger _logger;
  String? _ghlToken;

  factory HttpService() {
    return _instance;
  }

  HttpService._internal() {
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

    // Add interceptor to include GHL token in all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_ghlToken != null) {
            options.headers['Authorization'] = 'Bearer $_ghlToken';
          }
          handler.next(options);
        },
      ),
    );
  }

  void setLogger(AppLogger logger) {
    _logger = logger;
  }

  /// Sets the GoHighLevel token for API authentication
  void setGhlToken(String token) {
    _ghlToken = token;
  }

  /// Gets the current GoHighLevel token
  String? get ghlToken => _ghlToken;

  /// Clears the GoHighLevel token
  void clearGhlToken() {
    _ghlToken = null;
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

    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
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

    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
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

    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
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

    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      return response;
    } on DioException catch (e) {
      rethrow;
    }
  }
}
