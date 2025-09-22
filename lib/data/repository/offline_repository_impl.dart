import '../../domain/repository/offline_repository.dart';
import '../../model/estimates/estimate_model.dart';
import '../../model/estimates/estimate_status.dart';
import '../../model/projects/project_model.dart';
import '../../service/local_storage_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class OfflineRepository implements IOfflineRepository {
  final LocalStorageService _localStorageService;
  final AppLogger _logger;

  OfflineRepository(this._localStorageService, this._logger);

  @override
  Future<Result<String>> saveEstimate(EstimateModel estimate) async {
    try {
      final id = await _localStorageService.saveEstimate(estimate);
      _logger.info('Estimate saved offline with ID: $id');
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
      final estimate = await _localStorageService.getEstimate(id);
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
      final estimates = await _localStorageService.getAllEstimates();
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
      final estimates = await _localStorageService.getUnsyncedEstimates();
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
      await _localStorageService.updateEstimate(estimate);
      _logger.info('Estimate updated offline with ID: ${estimate.id}');
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
      await _localStorageService.markEstimateAsSynced(id);
      _logger.info('Estimate marked as synced: $id');
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
      await _localStorageService.deleteEstimate(id);
      _logger.info('Estimate deleted from offline storage: $id');
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
      final id = await _localStorageService.saveProject(project);
      _logger.info('Project saved offline with ID: $id');
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
      final projects = await _localStorageService.getAllProjects();
      _logger.info(
        'OfflineRepository: Found ${projects.length} projects in local storage',
      );
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

      await _localStorageService.updateEstimate(estimate);
      _logger.info('Project updated offline with ID: ${project.id}');
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
      await _localStorageService.deleteEstimate(projectId);
      _logger.info('Project deleted from offline storage: $projectId');
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
      await _localStorageService.addPendingOperation(operationType, data);
      _logger.info('Pending operation added: $operationType');
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
      final operations = await _localStorageService.getPendingOperations();
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
      await _localStorageService.removePendingOperation(id);
      _logger.info('Pending operation removed: $id');
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
      await _localStorageService.incrementRetryCount(id);
      _logger.info('Retry count incremented for operation: $id');
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
      await _localStorageService.close();
      _logger.info('All offline data cleared');
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
      final estimates = await _localStorageService.getAllEstimates();
      final pendingOps = await _localStorageService.getPendingOperations();

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
