import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'i_http_service.dart';
import '../config/app_config.dart';

class HttpService implements IHttpService {
  static final HttpService _instance = HttpService._internal();
  late final Dio dio;

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

  @override
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final fullPath = '${dio.options.baseUrl}$path';
    if (kDebugMode) {
      print('--> GET $fullPath');
    }
    try {
      final response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (kDebugMode) {
        print('<-- ${response.statusCode} GET $fullPath');
      }
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('<-- ${e.response?.statusCode ?? 'ERROR'} GET $fullPath: $e');
      }
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
    if (kDebugMode) {
      print('--> POST $fullPath');
    }
    try {
      final response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (kDebugMode) {
        print('<-- ${response.statusCode} POST $fullPath');
      }
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('<-- ${e.response?.statusCode ?? 'ERROR'} POST $fullPath: $e');
      }
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
    if (kDebugMode) {
      print('--> PUT $fullPath');
    }
    try {
      final response = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (kDebugMode) {
        print('<-- ${response.statusCode} PUT $fullPath');
      }
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('<-- ${e.response?.statusCode ?? 'ERROR'} PUT $fullPath: $e');
      }
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
    if (kDebugMode) {
      print('--> PATCH $fullPath');
    }
    try {
      final response = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (kDebugMode) {
        print('<-- ${response.statusCode} PATCH $fullPath');
      }
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('<-- ${e.response?.statusCode ?? 'ERROR'} PATCH $fullPath: $e');
      }
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
    if (kDebugMode) {
      print('--> DELETE $fullPath');
    }
    try {
      final response = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      if (kDebugMode) {
        print('<-- ${response.statusCode} DELETE $fullPath');
      }
      return response;
    } on DioException catch (e) {
      if (kDebugMode) {
        print('<-- ${e.response?.statusCode ?? 'ERROR'} DELETE $fullPath: $e');
      }
      rethrow;
    }
  }
}
