import '../../model/estimates/estimate_detail_model.dart';
import '../../utils/result/result.dart';

abstract class IEstimateDetailRepository {
  /// Get estimate details by ID
  Future<Result<EstimateDetailModel>> getEstimateDetail(int estimateId);

  /// Get estimate details by project ID (if projects are linked to estimates)
  Future<Result<EstimateDetailModel>> getEstimateDetailByProjectId(
    int projectId,
  );
}
