import '../../domain/repository/offline_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/projects/project_model.dart';
import '../../service/local/estimates_local_service.dart';
import '../../service/local/pending_operations_local_service.dart';
import '../../service/database_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class OfflineRepository implements IOfflineRepository {
  final EstimatesLocalService _estimatesLocalService;
  final PendingOperationsLocalService _pendingOpsService;
  final DatabaseService _databaseService;
  final AppLogger _logger;

  OfflineRepository(
    this._estimatesLocalService,
    this._pendingOpsService,
    this._databaseService,
    this._logger,
  );

  @override
  Future<Result<String>> saveEstimate(EstimateModel estimate) async {
    try {
      final id = await _estimatesLocalService.saveEstimate(estimate);

      return Result.ok(id);
    } catch (e) {
      _logger.error('Error saving estimate offline: $e', e);
      return Result.error(
        Exception('Failed to save estimate offline'),
      );
    }
  }

  @override
  Future<Result<EstimateModel?>> getEstimate(String id) async {
    try {
      final estimate = await _estimatesLocalService.getEstimate(id);
      return Result.ok(estimate);
    } catch (e) {
      _logger.error('Error getting estimate from offline storage: $e', e);
      return Result.error(
        Exception('Failed to get estimate from offline storage'),
      );
    }
  }

  @override
  Future<Result<List<EstimateModel>>> getAllEstimates() async {
    try {
      final estimates = await _estimatesLocalService.getAllEstimates();
      return Result.ok(estimates);
    } catch (e) {
      _logger.error('Error getting all estimates from offline storage: $e', e);
      return Result.error(
        Exception('Failed to get estimates from offline storage'),
      );
    }
  }

  @override
  Future<Result<List<EstimateModel>>> getUnsyncedEstimates() async {
    try {
      final estimates = await _estimatesLocalService.getUnsyncedEstimates();
      return Result.ok(estimates);
    } catch (e) {
      _logger.error('Error getting unsynced estimates: $e', e);
      return Result.error(
        Exception('Failed to get unsynced estimates'),
      );
    }
  }

  @override
  Future<Result<void>> updateEstimate(EstimateModel estimate) async {
    try {
      await _estimatesLocalService.updateEstimate(estimate);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error updating estimate offline: $e', e);
      return Result.error(
        Exception('Failed to update estimate offline'),
      );
    }
  }

  @override
  Future<Result<void>> markEstimateAsSynced(String id) async {
    try {
      await _estimatesLocalService.markEstimateAsSynced(id);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error marking estimate as synced: $e', e);
      return Result.error(
        Exception('Failed to mark estimate as synced'),
      );
    }
  }

  @override
  Future<Result<void>> deleteEstimate(String id) async {
    try {
      await _estimatesLocalService.deleteEstimate(id);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error deleting estimate from offline storage: $e', e);
      return Result.error(
        Exception('Failed to delete estimate from offline storage'),
      );
    }
  }

  @override
  Future<Result<String>> saveProject(ProjectModel project) async {
    try {
      final id = await _estimatesLocalService.saveProject(project);

      return Result.ok(id);
    } catch (e) {
      _logger.error('Error saving project offline: $e', e);
      return Result.error(
        Exception('Failed to save project offline'),
      );
    }
  }

  @override
  Future<Result<List<ProjectModel>>> getAllProjects() async {
    try {
      final projects = await _estimatesLocalService.getAllProjects();

      return Result.ok(projects);
    } catch (e) {
      _logger.error('Error getting all projects from offline storage: $e', e);
      return Result.error(
        Exception('Failed to get projects from offline storage'),
      );
    }
  }

  @override
  Future<Result<void>> updateProject(ProjectModel project) async {
    try {
      // Convert project to estimate for storage
      final estimate = EstimateModel(
        id: project.id.toString(),
        projectName: project.projectName,
        clientName: project.personName,
        status: EstimateStatus.draft,
        updatedAt: DateTime.now(),
      );

      await _estimatesLocalService.updateEstimate(estimate);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error updating project offline: $e', e);
      return Result.error(
        Exception('Failed to update project offline'),
      );
    }
  }

  @override
  Future<Result<void>> deleteProject(String projectId) async {
    try {
      await _estimatesLocalService.deleteEstimate(projectId);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error deleting project from offline storage: $e', e);
      return Result.error(
        Exception('Failed to delete project from offline storage'),
      );
    }
  }

  @override
  Future<Result<void>> addPendingOperation(
    String operationType,
    Map<String, dynamic> data,
  ) async {
    try {
      await _pendingOpsService.addPendingOperation(operationType, data);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error adding pending operation: $e', e);
      return Result.error(
        Exception('Failed to add pending operation'),
      );
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getPendingOperations() async {
    try {
      final operations = await _pendingOpsService.getPendingOperations();
      return Result.ok(operations);
    } catch (e) {
      _logger.error('Error getting pending operations: $e', e);
      return Result.error(
        Exception('Failed to get pending operations'),
      );
    }
  }

  @override
  Future<Result<void>> removePendingOperation(int id) async {
    try {
      await _pendingOpsService.removePendingOperation(id);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error removing pending operation: $e', e);
      return Result.error(
        Exception('Failed to remove pending operation'),
      );
    }
  }

  @override
  Future<Result<void>> incrementRetryCount(int id) async {
    try {
      await _pendingOpsService.incrementRetryCount(id);

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error incrementing retry count: $e', e);
      return Result.error(
        Exception('Failed to increment retry count'),
      );
    }
  }

  @override
  Future<Result<void>> clearAllData() async {
    try {
      await _databaseService.close();

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error clearing all data: $e', e);
      return Result.error(
        Exception('Failed to clear all data'),
      );
    }
  }

  @override
  Future<Result<Map<String, int>>> getStorageStats() async {
    try {
      final estimates = await _estimatesLocalService.getAllEstimates();
      final pendingOps = await _pendingOpsService.getPendingOperations();

      return Result.ok({
        'total_estimates': estimates.length,
        'unsynced_estimates': estimates.where((e) => e.id != null).length,
        'pending_operations': pendingOps.length,
      });
    } catch (e) {
      _logger.error('Error getting storage stats: $e', e);
      return Result.error(
        Exception('Failed to get storage stats'),
      );
    }
  }
}
