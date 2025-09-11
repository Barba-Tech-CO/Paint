import '../../domain/repository/estimate_repository.dart';
import '../../model/estimates/estimate_create_request.dart';
import '../../model/estimates/estimate_model.dart';
import '../../service/estimate_service.dart';
import '../../utils/result/result.dart';

class EstimateRepository implements IEstimateRepository {
  final EstimateService _estimateService;

  EstimateRepository({required EstimateService estimateService})
    : _estimateService = estimateService;

  @override
  Future<Result<Map<String, dynamic>>> getDashboard() {
    return _estimateService.getDashboardData();
  }

  @override
  Future<Result<List<EstimateModel>>> getEstimates({
    int? limit,
    int? offset,
    String? status,
  }) {
    return _estimateService.getEstimates(
      limit: limit,
      offset: offset,
      status: status,
    );
  }

  @override
  Future<Result<EstimateModel>> createEstimate(Map<String, dynamic> data) {
    return _estimateService.createEstimate(data);
  }

  @override
  Future<Result<EstimateModel>> getEstimate(String estimateId) {
    return _estimateService.getEstimate(estimateId);
  }

  @override
  Future<Result<EstimateModel>> updateEstimate(
    String estimateId,
    Map<String, dynamic> data,
  ) {
    return _estimateService.updateEstimate(estimateId, data);
  }

  @override
  Future<Result<bool>> deleteEstimate(String estimateId) {
    return _estimateService.deleteEstimate(estimateId);
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

  @override
  Future<Result<EstimateModel>> createEstimateMultipart(
    EstimateCreateRequest request,
  ) {
    return _estimateService.createEstimateMultipart(request);
  }
}
