import 'package:dio/dio.dart';

abstract class IHttpService {
  /// Sets the GoHighLevel token for API authentication
  void setGhlToken(String token);

  /// Gets the current GoHighLevel token
  String? get ghlToken;

  /// Clears the GoHighLevel token
  void clearGhlToken();

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  });
}
