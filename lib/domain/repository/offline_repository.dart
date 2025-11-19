import '../../model/estimates/estimate_model.dart';
import '../../model/projects/project_model.dart';
import '../../utils/result/result.dart';

abstract class IOfflineRepository {
  // Estimate operations
  Future<Result<String>> saveEstimate(EstimateModel estimate);
  Future<Result<EstimateModel?>> getEstimate(String id);
  Future<Result<List<EstimateModel>>> getAllEstimates();
  Future<Result<List<EstimateModel>>> getUnsyncedEstimates();
  Future<Result<void>> updateEstimate(EstimateModel estimate);
  Future<Result<void>> markEstimateAsSynced(String id);
  Future<Result<void>> deleteEstimate(String id);

  // Project operations
  Future<Result<String>> saveProject(ProjectModel project);
  Future<Result<List<ProjectModel>>> getAllProjects();
  Future<Result<void>> updateProject(ProjectModel project);
  Future<Result<void>> deleteProject(String projectId);

  // Sync operations
  Future<Result<void>> addPendingOperation(
    String operationType,
    Map<String, dynamic> data,
  );
  Future<Result<List<Map<String, dynamic>>>> getPendingOperations();
  Future<Result<void>> removePendingOperation(int id);
  Future<Result<void>> incrementRetryCount(int id);

  // Utility operations
  Future<Result<void>> clearAllData();
  Future<Result<Map<String, int>>> getStorageStats();
}
