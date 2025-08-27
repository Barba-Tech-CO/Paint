import '../../model/models.dart';
import '../../utils/result/result.dart';

abstract class IEstimateRepository {
  /// Obtém dados do dashboard
  Future<Result<Map<String, dynamic>>> getDashboard();

  /// Lista orçamentos com filtros e paginação
  Future<Result<List<EstimateModel>>> getEstimates({
    int? limit,
    int? offset,
    String? status,
  });

  /// Cria um novo orçamento
  Future<Result<EstimateModel>> createEstimate(Map<String, dynamic> data);

  /// Obtém detalhes de um orçamento
  Future<Result<EstimateModel>> getEstimate(String estimateId);

  /// Atualiza um orçamento
  Future<Result<EstimateModel>> updateEstimate(
    String estimateId,
    Map<String, dynamic> data,
  );

  /// Remove um orçamento
  Future<Result<bool>> deleteEstimate(String estimateId);

  /// Atualiza o status de um orçamento
  Future<Result<EstimateModel>> updateEstimateStatus(
    String estimateId,
    String status,
  );

  /// Upload de fotos para um orçamento
  Future<Result<List<String>>> uploadPhotos(
    String estimateId,
    List<String> photoPaths,
  );

  /// Seleciona elementos para um orçamento
  Future<Result<Map<String, dynamic>>> selectElements(
    String estimateId,
    List<String> elementIds,
  );

  /// Finaliza o orçamento
  Future<Result<EstimateModel>> finalizeEstimate(String estimateId);

  /// Envia o orçamento para o GHL
  Future<Result<bool>> sendToGHL(String estimateId);
}
