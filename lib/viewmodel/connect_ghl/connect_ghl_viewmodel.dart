import 'package:flutter/material.dart';

import '../../domain/repository/ghl_repository.dart';
import '../../model/ghl/ghl_config_model.dart';
import '../../service/auth_service.dart';
import '../../service/ghl/ghl_repository_impl.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ConnectGhlViewModel extends ChangeNotifier {
  final IGhlRepository _ghlRepository;
  final AuthService _authService;
  final AppLogger _logger;

  ConnectGhlViewModel(
    this._ghlRepository,
    this._authService,
    this._logger,
  );

  GhlConfigModel? _ghlConfig;
  bool _isLoading = false;
  String? _error;
  String? _apiKeyError;
  String? _locationIdError;
  bool _hasExistingConfig = false;

  // Getters
  GhlConfigModel? get ghlConfig => _ghlConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get apiKeyError => _apiKeyError;
  String? get locationIdError => _locationIdError;

  bool get hasError => _error != null;
  bool get hasGhlConfig => _ghlConfig != null;
  bool get hasExistingConfig => _hasExistingConfig;

  Future<void> loadGhlData() async {
    _setLoading(true);
    _setError(null);

    try {
      final userResult = await _authService.getUser();

      if (userResult is Error) {
        throw Exception('Could not authenticate user');
      }

      final userId = userResult.asOk.value.id.toString();

      final repository = _ghlRepository;
      if (repository is GhlRepositoryImpl) {
        final result = await repository.getGhlConfigFromServer(userId);
        _handleConfigResult(result);
      }
    } catch (e) {
      _setError('Error loading GHL data: $e');
      _logger.error('[ConnectGhlViewModel] Load failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _handleConfigResult(Result<GhlConfigModel> result) {
    if (result is Ok<GhlConfigModel>) {
      _ghlConfig = result.asOk.value;
      _hasExistingConfig =
          _ghlConfig != null &&
          _ghlConfig!.apiKey.isNotEmpty &&
          _ghlConfig!.locationId.isNotEmpty;
    } else if (result is Error<GhlConfigModel>) {
      final errorMessage = result.asError.error.toString();
      _setError(errorMessage);
      _logger.error('[ConnectGhlViewModel] Load config failed: $errorMessage');
    }
  }

  Future<void> saveGhlConfiguration({
    required String apiKey,
    required String locationId,
  }) async {
    _clearFieldErrors();
    _setLoading(true);
    _setError(null);

    if (apiKey.trim().isEmpty) {
      _setApiKeyError('API Key is required');
      _setLoading(false);
      return;
    }

    if (locationId.trim().isEmpty) {
      _setLocationIdError('Location ID is required');
      _setLoading(false);
      return;
    }

    try {
      final userResult = await _authService.getUser();

      if (userResult is Error) {
        _setError('Could not authenticate user. Please login again.');
        _setLoading(false);
        return;
      }

      final userId = userResult.asOk.value.id.toString();

      final config = GhlConfigModel(
        apiKey: apiKey.trim(),
        locationId: locationId.trim(),
        isConnected: true,
      );

      // Save to server
      final repository = _ghlRepository;
      if (repository is! GhlRepositoryImpl) {
        throw Exception('Repository not configured correctly');
      }

      final result = await repository.saveGhlConfigToServer(
        userId,
        config,
        isUpdate: _hasExistingConfig,
      );

      if (result is Ok<GhlConfigModel>) {
        _ghlConfig = result.asOk.value;
        _hasExistingConfig = true;
      } else if (result is Error<GhlConfigModel>) {
        final errorMessage = result.asError.error.toString();
        _setError(errorMessage);
        _logger.error('[ConnectGhlViewModel] Save failed: $errorMessage');
      }
    } catch (e) {
      _setError('Error saving GHL configuration: $e');
      _logger.error('[ConnectGhlViewModel] Save error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  void _setApiKeyError(String? error) {
    _apiKeyError = error;
    notifyListeners();
  }

  void _setLocationIdError(String? error) {
    _locationIdError = error;
    notifyListeners();
  }

  void _clearFieldErrors() {
    _apiKeyError = null;
    _locationIdError = null;
    notifyListeners();
  }

  void clearError() {
    _setError(null);
  }

  Future<void> deleteGhlConfiguration() async {
    _setLoading(true);
    _setError(null);

    try {
      final userResult = await _authService.getUser();

      if (userResult is Error) {
        throw Exception('Could not authenticate user');
      }

      final userId = userResult.asOk.value.id.toString();

      final repository = _ghlRepository;
      if (repository is! GhlRepositoryImpl) {
        throw Exception('Repository not configured correctly');
      }

      final result = await repository.disconnectFromServer(userId);
      _handleDeleteResult(result);
    } catch (e) {
      _setError('Error deleting GHL configuration: $e');
      _logger.error('[ConnectGhlViewModel] Delete error: $e');
    } finally {
      _setLoading(false);
    }
  }

  void _handleDeleteResult(Result<void> result) {
    if (result is Ok<void>) {
      _ghlConfig = null;
      _hasExistingConfig = false;
    } else if (result is Error<void>) {
      final errorMessage = result.asError.error.toString();
      _setError(errorMessage);
      _logger.error('[ConnectGhlViewModel] Delete failed: $errorMessage');
    }
  }
}
