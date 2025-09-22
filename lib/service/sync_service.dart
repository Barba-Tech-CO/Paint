import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../domain/repository/estimate_repository.dart';
import '../domain/repository/offline_repository.dart';
import '../model/estimates/estimate_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';

class SyncService {
  final IEstimateRepository _estimateRepository;
  final IOfflineRepository _offlineRepository;
  final Connectivity _connectivity;
  final AppLogger _logger;

  SyncService(
    this._estimateRepository,
    this._offlineRepository,
    this._connectivity,
    this._logger,
  );

  /// Check if device is online
  Future<bool> isOnline() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      _logger.error('Error checking connectivity: $e', e);
      return false;
    }
  }

  /// Sync all unsynced estimates to the API
  Future<Result<void>> syncEstimates() async {
    try {
      if (!await isOnline()) {
        _logger.info('Device is offline, skipping sync');
        return Result.ok(null);
      }

      final unsyncedResult = await _offlineRepository.getUnsyncedEstimates();
      if (unsyncedResult is Error) {
        return Result.error(unsyncedResult.asError.error);
      }

      final unsyncedEstimates = unsyncedResult.asOk.value;
      _logger.info('Found ${unsyncedEstimates.length} unsynced estimates');

      for (final estimate in unsyncedEstimates) {
        try {
          // Try to create estimate on API
          final createResult = await _estimateRepository
              .createEstimateMultipart(
                estimate,
              );

          if (createResult is Ok<EstimateModel>) {
            final syncedEstimate = createResult.asOk.value;

            // Update local estimate with API response
            await _offlineRepository.updateEstimate(syncedEstimate);

            // Mark as synced
            await _offlineRepository.markEstimateAsSynced(syncedEstimate.id!);

            _logger.info('Successfully synced estimate: ${estimate.id}');
          } else {
            _logger.error(
              'Failed to sync estimate ${estimate.id}: ${createResult.asError.error}',
            );

            // Add to pending operations for retry
            await _offlineRepository.addPendingOperation(
              'create_estimate',
              estimate.toJson(),
            );
          }
        } catch (e) {
          _logger.error('Error syncing estimate ${estimate.id}: $e', e);

          // Add to pending operations for retry
          await _offlineRepository.addPendingOperation(
            'create_estimate',
            estimate.toJson(),
          );
        }
      }

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error during estimate sync: $e', e);
      return Result.error(Exception('Failed to sync estimates: $e'));
    }
  }

  /// Sync pending operations
  Future<Result<void>> syncPendingOperations() async {
    try {
      if (!await isOnline()) {
        _logger.info('Device is offline, skipping pending operations sync');
        return Result.ok(null);
      }

      final pendingOpsResult = await _offlineRepository.getPendingOperations();
      if (pendingOpsResult is Error) {
        return Result.error(pendingOpsResult.asError.error);
      }

      final pendingOps = pendingOpsResult.asOk.value;
      _logger.info('Found ${pendingOps.length} pending operations');

      for (final operation in pendingOps) {
        try {
          final operationType = operation['operation_type'] as String;
          final data =
              jsonDecode(operation['data'] as String) as Map<String, dynamic>;
          final operationId = operation['id'] as int;

          bool success = false;

          switch (operationType) {
            case 'create_estimate':
              final estimate = EstimateModel.fromJson(data);
              final result = await _estimateRepository.createEstimateMultipart(
                estimate,
              );
              success = result is Ok<EstimateModel>;
              break;

            case 'update_estimate':
              final estimate = EstimateModel.fromJson(data);
              final result = await _estimateRepository.updateEstimate(
                estimate.id!,
                estimate.toJson(),
              );
              success = result is Ok<EstimateModel>;
              break;

            case 'delete_estimate':
              final estimateId = data['id'] as String;
              final result = await _estimateRepository.deleteEstimate(
                estimateId,
              );
              success = result is Ok<bool>;
              break;

            default:
              _logger.warning('Unknown operation type: $operationType');
              continue;
          }

          if (success) {
            await _offlineRepository.removePendingOperation(operationId);
            _logger.info('Successfully synced operation: $operationType');
          } else {
            // Increment retry count
            await _offlineRepository.incrementRetryCount(operationId);
            _logger.warning(
              'Failed to sync operation: $operationType, retry count incremented',
            );
          }
        } catch (e) {
          _logger.error('Error syncing operation ${operation['id']}: $e', e);

          // Increment retry count
          await _offlineRepository.incrementRetryCount(operation['id'] as int);
        }
      }

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error during pending operations sync: $e', e);
      return Result.error(Exception('Failed to sync pending operations: $e'));
    }
  }

  /// Full sync - estimates and pending operations
  Future<Result<void>> fullSync() async {
    try {
      _logger.info('Starting full sync...');

      // First sync estimates
      final estimatesResult = await syncEstimates();
      if (estimatesResult is Error) {
        _logger.error(
          'Error syncing estimates: ${estimatesResult.asError.error}',
        );
      }

      // Then sync pending operations
      final pendingResult = await syncPendingOperations();
      if (pendingResult is Error) {
        _logger.error(
          'Error syncing pending operations: ${pendingResult.asError.error}',
        );
      }

      _logger.info('Full sync completed');
      return Result.ok(null);
    } catch (e) {
      _logger.error('Error during full sync: $e', e);
      return Result.error(Exception('Failed to perform full sync: $e'));
    }
  }

  /// Auto-sync when connectivity is restored
  Future<void> startAutoSync() async {
    _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.isNotEmpty && results.first != ConnectivityResult.none) {
        _logger.info('Connectivity restored, starting auto-sync');
        fullSync();
      }
    });
  }

  /// Get sync status
  Future<Result<Map<String, dynamic>>> getSyncStatus() async {
    try {
      final isOnlineStatus = await isOnline();
      final statsResult = await _offlineRepository.getStorageStats();

      if (statsResult is Error) {
        return Result.error(statsResult.asError.error);
      }

      final stats = statsResult.asOk.value;

      return Result.ok({
        'is_online': isOnlineStatus,
        'total_estimates': stats['total_estimates'],
        'unsynced_estimates': stats['unsynced_estimates'],
        'pending_operations': stats['pending_operations'],
      });
    } catch (e) {
      _logger.error('Error getting sync status: $e', e);
      return Result.error(Exception('Failed to get sync status: $e'));
    }
  }
}
