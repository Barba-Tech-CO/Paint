import '../../domain/repository/estimate_repository.dart';
import '../../domain/repository/offline_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../service/estimate_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class EstimateRepository implements IEstimateRepository {
  final EstimateService _estimateService;
  final IOfflineRepository _offlineRepository;
  final AppLogger _logger;

  EstimateRepository({
    required EstimateService estimateService,
    required IOfflineRepository offlineRepository,
    required AppLogger logger,
  }) : _estimateService = estimateService,
       _offlineRepository = offlineRepository,
       _logger = logger;

  @override
  Future<Result<Map<String, dynamic>>> getDashboard() {
    return _estimateService.getDashboardData();
  }

  @override
  Future<Result<List<EstimateModel>>> getEstimates({
    int? limit,
    int? offset,
    String? status,
  }) async {
    try {
      // Offline-first strategy: Always try to sync from API first
      _logger.info('EstimateRepository: Attempting to sync estimates from API');
      final syncResult = await _pullEstimatesFromApi();

      if (syncResult is Ok) {
        // After successful sync, get data from offline storage
        final offlineResult = await _offlineRepository.getAllEstimates();

        if (offlineResult is Ok<List<EstimateModel>>) {
          final syncedEstimates = offlineResult.asOk.value;

          // Apply filters to synced data
          List<EstimateModel> filteredEstimates = syncedEstimates;

          if (status != null) {
            filteredEstimates = filteredEstimates
                .where((e) => e.status.name == status)
                .toList();
          }

          if (limit != null) {
            final startIndex = offset ?? 0;
            filteredEstimates = filteredEstimates
                .skip(startIndex)
                .take(limit)
                .toList();
          }

          _logger.info(
            'EstimateRepository: Successfully synced and loaded ${filteredEstimates.length} estimates',
          );
          return Result.ok(filteredEstimates);
        }
      } else {
        _logger.warning(
          'EstimateRepository: Failed to sync estimates from API: ${syncResult.asError.error}',
        );

        // If API fails, try to get existing offline data
        final offlineResult = await _offlineRepository.getAllEstimates();

        if (offlineResult is Ok<List<EstimateModel>>) {
          final offlineEstimates = offlineResult.asOk.value;

          if (offlineEstimates.isNotEmpty) {
            _logger.info(
              'EstimateRepository: Found ${offlineEstimates.length} estimates in offline storage',
            );

            // Apply filters to offline data
            List<EstimateModel> filteredEstimates = offlineEstimates;

            // Filter by status if provided
            if (status != null) {
              filteredEstimates = filteredEstimates
                  .where((e) => e.status.name == status)
                  .toList();
            }

            // Apply limit and offset
            if (limit != null) {
              final startIndex = offset ?? 0;
              filteredEstimates = filteredEstimates
                  .skip(startIndex)
                  .take(limit)
                  .toList();
            }

            return Result.ok(filteredEstimates);
          }
        }

        return Result.error(
          Exception('No estimates available offline and API sync failed'),
        );
      }

      return Result.error(
        Exception(
          'Failed to get estimates from offline storage after API sync',
        ),
      );
    } catch (e) {
      _logger.error('EstimateRepository: Error in getEstimates: $e', e);
      return Result.error(
        Exception('Failed to get estimates'),
      );
    }
  }

  @override
  Future<Result<EstimateModel>> createEstimate(
    Map<String, dynamic> data,
  ) async {
    try {
      // Try to create estimate via API first
      final apiResult = await _estimateService.createEstimate(data);

      if (apiResult is Ok<EstimateModel>) {
        final estimate = apiResult.asOk.value;

        // Cache the newly created estimate for offline access
        await _offlineRepository.saveEstimate(estimate);
        _logger.info(
          'EstimateRepository: Cached newly created estimate ${estimate.id}',
        );

        return Result.ok(estimate);
      }

      return apiResult;
    } catch (e) {
      _logger.error('EstimateRepository: Error in createEstimate: $e', e);
      return Result.error(
        Exception('Failed to create estimate'),
      );
    }
  }

  @override
  Future<Result<EstimateModel>> createEstimateMultipart(
    EstimateModel estimate,
  ) async {
    try {
      // Try to create estimate via API first
      final apiResult = await _estimateService.createEstimateMultipart(
        estimate,
      );

      if (apiResult is Ok<EstimateModel>) {
        final createdEstimate = apiResult.asOk.value;

        // Cache the newly created estimate for offline access
        await _offlineRepository.saveEstimate(createdEstimate);
        _logger.info(
          'EstimateRepository: Cached newly created multipart estimate ${createdEstimate.id}',
        );

        return Result.ok(createdEstimate);
      }

      return apiResult;
    } catch (e) {
      _logger.error(
        'EstimateRepository: Error in createEstimateMultipart: $e',
        e,
      );
      return Result.error(
        Exception('Failed to create estimate'),
      );
    }
  }

  @override
  Future<Result<EstimateModel>> getEstimate(String estimateId) async {
    try {
      // Offline-first strategy: Try to get estimate from local storage first
      _logger.info(
        'EstimateRepository: Attempting to load estimate $estimateId from offline storage',
      );

      final offlineResult = await _offlineRepository.getEstimate(estimateId);

      if (offlineResult is Ok<EstimateModel?>) {
        final offlineEstimate = offlineResult.asOk.value;

        if (offlineEstimate != null) {
          _logger.info(
            'EstimateRepository: Found estimate $estimateId in offline storage',
          );

          // Try to sync in background to get latest data
          _syncEstimateInBackground(estimateId);

          return Result.ok(offlineEstimate);
        } else {
          _logger.info(
            'EstimateRepository: Estimate $estimateId not found in offline storage, trying API',
          );
        }
      } else {
        _logger.warning(
          'EstimateRepository: Failed to load estimate $estimateId from offline storage: ${offlineResult.asError.error}',
        );
      }

      // If not found offline, try API and cache the result
      _logger.info(
        'EstimateRepository: Attempting to load estimate $estimateId from API',
      );
      final apiResult = await _estimateService.getEstimate(estimateId);

      if (apiResult is Ok<EstimateModel>) {
        final estimate = apiResult.asOk.value;

        // Cache the estimate for future offline access
        await _offlineRepository.saveEstimate(estimate);
        _logger.info(
          'EstimateRepository: Cached estimate $estimateId from API',
        );

        return Result.ok(estimate);
      }

      return apiResult;
    } catch (e) {
      _logger.error('EstimateRepository: Error in getEstimate: $e', e);
      return Result.error(
        Exception('Failed to get estimate'),
      );
    }
  }

  @override
  Future<Result<EstimateModel>> updateEstimate(
    String estimateId,
    Map<String, dynamic> data,
  ) async {
    try {
      // Try to update estimate via API first
      final apiResult = await _estimateService.updateEstimate(estimateId, data);

      if (apiResult is Ok<EstimateModel>) {
        final updatedEstimate = apiResult.asOk.value;

        // Update the cached estimate
        await _offlineRepository.updateEstimate(updatedEstimate);
        _logger.info('EstimateRepository: Updated cached estimate $estimateId');

        return Result.ok(updatedEstimate);
      }

      return apiResult;
    } catch (e) {
      _logger.error('EstimateRepository: Error in updateEstimate: $e', e);
      return Result.error(
        Exception('Failed to update estimate'),
      );
    }
  }

  @override
  Future<Result<bool>> deleteEstimate(String estimateId) async {
    try {
      // Try to delete estimate via API first
      final apiResult = await _estimateService.deleteEstimate(estimateId);

      if (apiResult is Ok<bool> && apiResult.asOk.value) {
        // Remove from offline cache
        await _offlineRepository.deleteEstimate(estimateId);
        _logger.info(
          'EstimateRepository: Removed deleted estimate $estimateId from cache',
        );

        return Result.ok(true);
      }

      return apiResult;
    } catch (e) {
      _logger.error('EstimateRepository: Error in deleteEstimate: $e', e);
      return Result.error(
        Exception('Failed to delete estimate'),
      );
    }
  }

  @override
  Future<Result<EstimateModel>> updateEstimateStatus(
    String estimateId,
    String status,
  ) {
    return _estimateService.updateEstimateStatus(estimateId, status);
  }

  @override
  Future<Result<List<String>>> uploadPhotos(
    String estimateId,
    List<String> photoPaths,
  ) {
    return _estimateService.uploadPhotos(estimateId, photoPaths);
  }

  @override
  Future<Result<Map<String, dynamic>>> selectElements(
    String estimateId,
    List<String> elementIds,
  ) {
    return _estimateService.selectElements(estimateId, elementIds);
  }

  @override
  Future<Result<EstimateModel>> finalizeEstimate(String estimateId) {
    return _estimateService.finalizeEstimate(estimateId);
  }

  @override
  Future<Result<bool>> sendToGHL(String estimateId) {
    return _estimateService.sendToGHL(estimateId);
  }

  /// Pull estimates from API to local storage
  Future<Result<void>> _pullEstimatesFromApi() async {
    try {
      final apiResult = await _estimateService.getEstimates(
        limit: 100,
        offset: 0,
      );

      if (apiResult is Ok<List<EstimateModel>>) {
        final estimates = apiResult.asOk.value;

        // Save each estimate to local storage
        for (final estimate in estimates) {
          try {
            await _offlineRepository.saveEstimate(estimate);
            await _offlineRepository.markEstimateAsSynced(estimate.id!);
          } catch (e) {
            _logger.error(
              'EstimateRepository: Error saving estimate ${estimate.id} to local storage: $e',
            );
          }
        }

        return Result.ok(null);
      } else {
        return Result.error(apiResult.asError.error);
      }
    } catch (e) {
      _logger.error(
        'EstimateRepository: Error during data pull from API: $e',
        e,
      );
      return Result.error(
        Exception('Failed to pull data from API'),
      );
    }
  }

  /// Sync specific estimate in background
  Future<void> _syncEstimateInBackground(String estimateId) async {
    try {
      final apiResult = await _estimateService.getEstimate(estimateId);

      if (apiResult is Ok<EstimateModel>) {
        final estimate = apiResult.asOk.value;
        await _offlineRepository.saveEstimate(estimate);
        await _offlineRepository.markEstimateAsSynced(estimateId);
        _logger.info(
          'EstimateRepository: Updated estimate $estimateId in background',
        );
      }
    } catch (e) {
      _logger.warning(
        'EstimateRepository: Failed to update estimate $estimateId in background: $e',
      );
    }
  }
}
