import 'dart:io';
import '../../domain/repository/estimate_repository.dart';
import '../../model/estimate_model.dart';
import '../../service/estimate_service.dart';
import '../../utils/result/result.dart';

class EstimateRepository implements IEstimateRepository {
  final EstimateService _estimateService;

  EstimateRepository({required EstimateService estimateService}) 
    : _estimateService = estimateService;

  @override
  Future<Result<DashboardResponse>> getDashboard() {
    return _estimateService.getDashboard();
  }

  @override
  Future<Result<EstimateListResponse>> getEstimates({
    int? limit,
    int? offset,
    EstimateStatus? status,
    ProjectType? projectType,
  }) {
    return _estimateService.getEstimates(
      limit: limit,
      offset: offset,
      status: status,
      projectType: projectType,
    );
  }

  @override
  Future<Result<EstimateResponse>> createEstimate({
    required String projectName,
    required String clientName,
    required ProjectType projectType,
  }) {
    return _estimateService.createEstimate(
      projectName: projectName,
      clientName: clientName,
      projectType: projectType,
    );
  }

  @override
  Future<Result<EstimateResponse>> getEstimate(String estimateId) {
    return _estimateService.getEstimate(estimateId);
  }

  @override
  Future<Result<EstimateResponse>> updateEstimate(
    String estimateId, {
    String? projectName,
    String? clientName,
    ProjectType? projectType,
  }) {
    return _estimateService.updateEstimate(
      estimateId,
      projectName: projectName,
      clientName: clientName,
      projectType: projectType,
    );
  }

  @override
  Future<Result<bool>> deleteEstimate(String estimateId) {
    return _estimateService.deleteEstimate(estimateId);
  }

  @override
  Future<Result<EstimateResponse>> updateEstimateStatus(
    String estimateId,
    EstimateStatus status,
  ) {
    return _estimateService.updateEstimateStatus(estimateId, status);
  }

  @override
  Future<Result<EstimateResponse>> uploadPhotos(
    String estimateId,
    List<File> photos,
  ) {
    return _estimateService.uploadPhotos(estimateId, photos);
  }

  @override
  Future<Result<EstimateResponse>> selectElements(
    String estimateId, {
    required bool useCatalog,
    required String brandKey,
    required String colorKey,
    required String usage,
    required String sizeKey,
  }) {
    return _estimateService.selectElements(
      estimateId,
      useCatalog: useCatalog,
      brandKey: brandKey,
      colorKey: colorKey,
      usage: usage,
      sizeKey: sizeKey,
    );
  }

  @override
  Future<Result<EstimateResponse>> completeEstimate(String estimateId) {
    return _estimateService.completeEstimate(estimateId);
  }

  @override
  Future<Result<bool>> sendToGHL(String estimateId) {
    return _estimateService.sendToGHL(estimateId);
  }
}