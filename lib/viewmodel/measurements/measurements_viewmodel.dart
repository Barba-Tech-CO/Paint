import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../domain/repository/offline_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/estimates/floor_dimensions_model.dart';
import '../../model/estimates/surface_areas_model.dart';
import '../../model/estimates/zone_data_model.dart';
import '../../model/estimates/zone_model.dart';
import '../../service/sync_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class MeasurementsViewModel extends ChangeNotifier {
  int _randomNumber = 0;
  Timer? _timer;
  final _random = Random();
  bool _isLoading = true;
  String? _error;

  final IOfflineRepository _offlineRepository;
  final SyncService _syncService;
  final AppLogger _logger;

  MeasurementsViewModel(
    this._offlineRepository,
    this._syncService,
    this._logger,
  ) {
    startRandomCalculation();
  }

  // Dados simulados - em produção viriam de um processamento real
  final Map<String, dynamic> _measurementResults = {
    'accuracy': 95.8,
    'floorDimensions': '14\' x 16\'',
    'floorArea': 224,
    'walls': 485,
    'ceiling': 224,
    'trim': 60,
    'totalPaintable': 631,
  };

  // Getters
  int get randomNumber => _randomNumber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get measurementResults => _measurementResults;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> startRandomCalculation() async {
    _setLoading(true);
    _clearError();

    try {
      final random = Random();
      final secondsToWait = random.nextInt(4) + 2;

      _timer = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _randomNumber = _random.nextInt(100);
        notifyListeners();
      });

      await Future.delayed(Duration(seconds: secondsToWait), () {
        if (_timer?.isActive == true) {
          _timer?.cancel();
          _setLoading(false);
        }
      });
    } catch (e) {
      _setError('Erro ao calcular: $e');
    }
  }

  // Métodos de gerenciamento de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Save measurement data as estimate offline
  Future<Result<String>> saveMeasurementData({
    required String projectName,
    required String clientName,
    String? contactId,
    String? additionalNotes,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Create estimate from measurement data
      final estimate = EstimateModel(
        projectName: projectName,
        clientName: clientName,
        contactId: contactId,
        additionalNotes: additionalNotes,
        status: EstimateStatus.draft,
        totalArea: _measurementResults['floorArea']?.toDouble(),
        paintableArea: _measurementResults['totalPaintable']?.toDouble(),
        zones: _createZonesFromMeasurements(),
        createdAt: DateTime.now(),
      );

      // Always save to offline storage first
      final offlineResult = await _offlineRepository.saveEstimate(estimate);
      if (offlineResult is Error) {
        _logger.error(
          'Failed to save measurement data offline: ${offlineResult.asError.error}',
        );
        _setError('Failed to save measurement data offline');
        return Result.error(
          Exception('Failed to save measurement data offline'),
        );
      }

      final estimateId = offlineResult.asOk.value;
      _logger.info('Measurement data saved offline with ID: $estimateId');

      // Try to sync with API if online
      final isOnline = await _syncService.isOnline();
      if (isOnline) {
        try {
          final syncResult = await _syncService.syncEstimates();
          if (syncResult is Ok) {
            _logger.info('Measurement data synced with API: $estimateId');
          } else {
            _logger.warning(
              'Failed to sync measurement data with API, saved offline only',
            );
          }
        } catch (e) {
          _logger.warning('Error syncing measurement data with API: $e');
        }
      } else {
        _logger.info('Device offline, measurement data saved locally only');
      }

      _setLoading(false);
      return Result.ok(estimateId);
    } catch (e) {
      _logger.error('Error saving measurement data: $e', e);
      _setError('Failed to save measurement data: $e');
      _setLoading(false);
      return Result.error(Exception('Failed to save measurement data: $e'));
    }
  }

  /// Create zones from measurement data
  List<ZoneModel> _createZonesFromMeasurements() {
    return [
      ZoneModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Main Room',
        zoneType: 'room',
        data: [
          ZoneDataModel(
            floorDimensions: FloorDimensionsModel(
              length: 14.0,
              width: 16.0,
              unit: 'ft',
            ),
            surfaceAreas: SurfaceAreasModel(
              values: {
                'walls': _measurementResults['walls']?.toDouble() ?? 0.0,
                'ceiling': _measurementResults['ceiling']?.toDouble() ?? 0.0,
                'trim': _measurementResults['trim']?.toDouble() ?? 0.0,
              },
            ),
            photoPaths: [],
          ),
        ],
      ),
    ];
  }

  /// Get sync status
  Future<Result<Map<String, dynamic>>> getSyncStatus() async {
    try {
      return await _syncService.getSyncStatus();
    } catch (e) {
      _logger.error('Error getting sync status: $e', e);
      return Result.error(Exception('Failed to get sync status: $e'));
    }
  }

  /// Force sync with API
  Future<Result<void>> forceSync() async {
    try {
      _setLoading(true);
      _clearError();

      final result = await _syncService.fullSync();
      if (result is Error) {
        _setError('Failed to sync data: ${result.asError.error}');
        return Result.error(result.asError.error);
      }

      _setLoading(false);
      return Result.ok(null);
    } catch (e) {
      _logger.error('Error during force sync: $e', e);
      _setError('Failed to sync data: $e');
      _setLoading(false);
      return Result.error(Exception('Failed to sync data: $e'));
    }
  }
}
