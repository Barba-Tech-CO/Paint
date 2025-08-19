import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../utils/logger/app_logger.dart';

class HttpService implements IHttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;
  late final AppLogger _logger;

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
  }

  void setLogger(AppLogger logger) {
    _logger = logger;
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

    LoggerService.info('--> POST $fullPath');

    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      LoggerService.info('<-- ${response.statusCode} POST $fullPath');
      return response;
    } on DioException catch (e) {
      LoggerService.error(
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

    LoggerService.info('--> PUT $fullPath');

    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      LoggerService.info('<-- ${response.statusCode} PUT $fullPath');
      return response;
    } on DioException catch (e) {
      LoggerService.error(
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

    LoggerService.info('--> PATCH $fullPath');

    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      LoggerService.info('<-- ${response.statusCode} PATCH $fullPath');
      return response;
    } on DioException catch (e) {
      LoggerService.error(
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

    LoggerService.info('--> DELETE $fullPath');

    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      LoggerService.info('<-- ${response.statusCode} DELETE $fullPath');
      return response;
    } on DioException catch (e) {
      LoggerService.error(
        '<-- ${e.response?.statusCode ?? 'ERROR'} DELETE $fullPath: $e',
      );
      rethrow;
    }
  }
}
