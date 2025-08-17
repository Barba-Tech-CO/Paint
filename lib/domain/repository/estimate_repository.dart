import 'dart:io';
import '../../model/estimate_model.dart';
import '../../utils/result/result.dart';

abstract class IEstimateRepository {
  /// Obtém dados do dashboard
  Future<Result<DashboardResponse>> getDashboard();

  /// Lista orçamentos com filtros e paginação
  Future<Result<EstimateListResponse>> getEstimates({
    int? limit,
    int? offset,
    EstimateStatus? status,
    ProjectType? projectType,
  });

  /// Cria um novo orçamento
  Future<Result<EstimateResponse>> createEstimate({
    required String projectName,
    required String clientName,
    required ProjectType projectType,
  });

  /// Obtém detalhes de um orçamento
  Future<Result<EstimateResponse>> getEstimate(String estimateId);

  /// Atualiza um orçamento
  Future<Result<EstimateResponse>> updateEstimate(
    String estimateId, {
    String? projectName,
    String? clientName,
    ProjectType? projectType,
  });

  /// Remove um orçamento
  Future<Result<bool>> deleteEstimate(String estimateId);

  /// Atualiza o status de um orçamento
  Future<Result<EstimateResponse>> updateEstimateStatus(
    String estimateId,
    EstimateStatus status,
  );

  /// Upload de fotos para um orçamento
  Future<Result<EstimateResponse>> uploadPhotos(
    String estimateId,
    List<File> photos,
  );

  /// Seleciona tintas e calcula custos
  Future<Result<EstimateResponse>> selectElements(
    String estimateId, {
    required bool useCatalog,
    required String brandKey,
    required String colorKey,
    required String usage,
    required String sizeKey,
  });

  /// Finaliza o orçamento
  Future<Result<EstimateResponse>> completeEstimate(String estimateId);

  /// Envia o orçamento para o GHL
  Future<Result<bool>> sendToGHL(String estimateId);
}