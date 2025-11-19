import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/repository/ghl_repository.dart';
import '../../model/ghl/ghl_config_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';
import 'ghl_service.dart';

class GhlRepositoryImpl implements IGhlRepository {
  static const String _keyGhlConfig = 'ghl_config';
  final GhlService _ghlService;
  final AppLogger _logger;

  GhlRepositoryImpl(this._ghlService, this._logger);

  @override
  Future<Result<GhlConfigModel>> getGhlConfig() async {
    try {
      // First try to get from local storage
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString(_keyGhlConfig);

      if (configJson != null) {
        final configMap = Map<String, dynamic>.from(
          Uri.splitQueryString(configJson),
        );

        // Convert string values to appropriate types
        final convertedMap = <String, dynamic>{
          'api_key': configMap['api_key'] ?? '',
          'location_id': configMap['location_id'] ?? '',
          'is_connected': configMap['is_connected'] == 'true',
          'last_sync_at':
              (configMap['last_sync_at'] != null &&
                  configMap['last_sync_at'] != 'null' &&
                  (configMap['last_sync_at'] as String).isNotEmpty)
              ? configMap['last_sync_at']
              : null,
        };

        final config = GhlConfigModel.fromJson(convertedMap);
        return Result.ok(config);
      }

      // If not found locally, return empty config
      return Result.ok(
        const GhlConfigModel(
          apiKey: '',
          locationId: '',
          isConnected: false,
        ),
      );
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Error getting GHL config: $e');
      return Result.error(
        Exception('Failed to load GHL configuration'),
      );
    }
  }

  Future<Result<GhlConfigModel>> getGhlConfigFromServer(String userId) async {
    try {
      final response = await _ghlService.getGhlCredentials(userId);

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final config = GhlConfigModel.fromJson(data);
          await _saveToLocalStorage(config);
          return Result.ok(config);
        }
      }

      return Result.error(
        Exception('Invalid response format'),
      );
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Failed to get config: $e');
      return Result.error(
        Exception('Failed to load GHL configuration from server'),
      );
    }
  }

  @override
  Future<Result<GhlConfigModel>> saveGhlConfig(GhlConfigModel config) async {
    try {
      // Save to local storage first
      await _saveToLocalStorage(config);

      _logger.info('[GhlRepositoryImpl] GHL config saved locally successfully');
      return Result.ok(config);
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Error saving GHL config: $e');
      return Result.error(
        Exception('Failed to save GHL configuration'),
      );
    }
  }

  Future<Result<GhlConfigModel>> saveGhlConfigToServer(
    String userId,
    GhlConfigModel config, {
    required bool isUpdate,
  }) async {
    try {
      final Response response;

      if (isUpdate) {
        response = await _ghlService.updateGhlCredentials(userId, config);
      } else {
        response = await _ghlService.createGhlCredentials(userId, config);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          final savedConfig = GhlConfigModel.fromJson(data);
          await _saveToLocalStorage(savedConfig);
          return Result.ok(savedConfig);
        }
      }

      return Result.error(Exception('Invalid response format'));
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Failed to save config: $e');
      return Result.error(
        Exception('Failed to save GHL configuration to server'),
      );
    }
  }

  Future<void> _saveToLocalStorage(GhlConfigModel config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = Uri(
      queryParameters: config.toJson().map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    ).query;
    await prefs.setString(_keyGhlConfig, configJson);
  }

  @override
  Future<Result<void>> disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGhlConfig);

      _logger.info('[GhlRepositoryImpl] GHL disconnected locally successfully');
      return Result.ok(null);
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Error disconnecting GHL: $e');
      return Result.error(
        Exception('Failed to disconnect GHL'),
      );
    }
  }

  Future<Result<void>> disconnectFromServer(String userId) async {
    try {
      await _ghlService.deleteGhlCredentials(userId);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyGhlConfig);
      return Result.ok(null);
    } catch (e) {
      _logger.error('[GhlRepositoryImpl] Failed to disconnect: $e');
      return Result.error(
        Exception('Failed to disconnect GHL from server'),
      );
    }
  }
}
