import '../../domain/repository/estimate_detail_repository.dart';
import '../../model/estimates/estimate_detail_model.dart';
import '../../utils/result/result.dart';

class EstimateDetailUseCase {
  final IEstimateDetailRepository _estimateDetailRepository;

  EstimateDetailUseCase(this._estimateDetailRepository);

  /// Get estimate details by estimate ID
  Future<Result<EstimateDetailModel>> getEstimateDetail(int estimateId) async {
    try {
      return await _estimateDetailRepository.getEstimateDetail(estimateId);
    } catch (e) {
      return Result.error(
        Exception('Error getting estimate details: $e'),
      );
    }
  }

  /// Get estimate details by project ID
  Future<Result<EstimateDetailModel>> getEstimateDetailByProjectId(
    int projectId,
  ) async {
    try {
      return await _estimateDetailRepository.getEstimateDetailByProjectId(
        projectId,
      );
    } catch (e) {
      return Result.error(
        Exception('Error getting estimate details by project ID: $e'),
      );
    }
  }

  /// Get estimate details and convert to overview zones format
  Future<Result<EstimateDetailModel>> getEstimateForOverview(
    int projectId,
  ) async {
    try {
      // In this system, projects and estimates are the same entity
      // The project ID is actually the estimate ID from the estimates table
      return await _estimateDetailRepository.getEstimateDetail(projectId);
    } catch (e) {
      return Result.error(
        Exception('Error getting estimate for overview: $e'),
      );
    }
  }
}
