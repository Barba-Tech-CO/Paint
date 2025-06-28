import 'package:dio/dio.dart';

abstract class IHttpService {
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters});
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  });
}
