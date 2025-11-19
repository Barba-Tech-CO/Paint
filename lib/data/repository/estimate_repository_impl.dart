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
      // Try to sync from API (offline-first). Proceed regardless of result.
      final syncOk = (await _pullEstimatesFromApi()) is Ok;

      // Always fetch from offline storage and apply filters.
      final offlineResult = await _offlineRepository.getAllEstimates();
      if (offlineResult is Ok<List<EstimateModel>>) {
        final all = offlineResult.asOk.value;
        if (all.isEmpty && !syncOk) {
          return Result.error(
            Exception('No estimates available offline and API sync failed'),
          );
        }
        return Result.ok(
          _applyFilters(
            all,
            limit: limit,
            offset: offset,
            status: status,
          ),
        );
      }

      return Result.error(
        Exception('Failed to get estimates from offline storage'),
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

      final offlineResult = await _offlineRepository.getEstimate(estimateId);

      if (offlineResult is Ok<EstimateModel?>) {
        final offlineEstimate = offlineResult.asOk.value;
        if (offlineEstimate != null) {
          _syncEstimateInBackground(estimateId);
          return Result.ok(offlineEstimate);
        }
      }

      // If not found offline, try API and cache the result
      final apiResult = await _estimateService.getEstimate(estimateId);

      if (apiResult is Ok<EstimateModel>) {
        final estimate = apiResult.asOk.value;

        // Cache the estimate for future offline access
        await _offlineRepository.saveEstimate(estimate);

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
        await _offlineRepository.deleteEstimate(estimateId);
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
            await _saveAndMarkSynced(estimate);
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

  List<EstimateModel> _applyFilters(
    List<EstimateModel> estimates, {
    int? limit,
    int? offset,
    String? status,
  }) {
    var filtered = estimates;
    if (status != null) {
      filtered = filtered.where((e) => e.status.name == status).toList();
    }
    if (limit != null) {
      final start = offset ?? 0;
      filtered = filtered.skip(start).take(limit).toList();
    }
    return filtered;
  }

  /// Sync specific estimate in background
  Future<void> _syncEstimateInBackground(String estimateId) async {
    try {
      final apiResult = await _estimateService.getEstimate(estimateId);

      if (apiResult is Ok<EstimateModel>) {
        final estimate = apiResult.asOk.value;
        await _saveAndMarkSynced(estimate);
      }
    } catch (e) {
      _logger.warning(
        'EstimateRepository: Failed to update estimate $estimateId in background: $e',
      );
    }
  }

  Future<void> _saveAndMarkSynced(EstimateModel estimate) async {
    await _offlineRepository.saveEstimate(estimate);
    final id = estimate.id;
    if (id != null && id.isNotEmpty) {
      await _offlineRepository.markEstimateAsSynced(id);
    }
  }
}
