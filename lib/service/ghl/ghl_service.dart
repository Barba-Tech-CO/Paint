import 'package:dio/dio.dart';

import '../../utils/logger/app_logger.dart';
import '../../model/ghl/ghl_config_model.dart';
import '../http_service.dart';

class GhlService {
  final HttpService _httpService;
  final AppLogger _logger;

  GhlService(this._httpService, this._logger);

  /// GET - Get GHL credentials for a user
  Future<Response> getGhlCredentials(String userId) async {
    try {
      return await _httpService.get('/users/$userId/ghl-credentials');
    } catch (e) {
      _logger.error(
        '[GhlService] GET /users/$userId/ghl-credentials failed: $e',
      );
      rethrow;
    }
  }

  /// POST - Create GHL credentials for a user
  Future<Response> createGhlCredentials(
    String userId,
    GhlConfigModel config,
  ) async {
    try {
      return await _httpService.post(
        '/users/$userId/ghl-credentials',
        data: {
          'token': config.apiKey,
          'locationId': config.locationId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        _logger.error(
          '[GhlService] POST failed - ${e.response?.statusCode}: ${e.response?.data}',
        );
      }
      rethrow;
    }
  }

  /// PUT - Update GHL credentials for a user
  Future<Response> updateGhlCredentials(
    String userId,
    GhlConfigModel config,
  ) async {
    try {
      return await _httpService.put(
        '/users/$userId/ghl-credentials',
        data: {
          'token': config.apiKey,
          'locationId': config.locationId,
        },
      );
    } catch (e) {
      if (e is DioException) {
        _logger.error(
          '[GhlService] PUT failed - ${e.response?.statusCode}: ${e.response?.data}',
        );
      }
      rethrow;
    }
  }

  /// DELETE - Delete GHL credentials for a user
  Future<Response> deleteGhlCredentials(String userId) async {
    try {
      return await _httpService.delete('/users/$userId/ghl-credentials');
    } catch (e) {
      _logger.error(
        '[GhlService] DELETE /users/$userId/ghl-credentials failed: $e',
      );
      rethrow;
    }
  }
}
