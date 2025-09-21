import 'package:dio/dio.dart';

import '../config/app_urls.dart';
import '../model/estimates/estimate_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class EstimateService {
  final HttpService _httpService;

  EstimateService(this._httpService);

  /// Obtém dados do dashboard
  Future<Result<Map<String, dynamic>>> getDashboardData() async {
    try {
      final response = await _httpService.get(
        '${AppUrls.estimatesBaseUrl}/dashboard',
      );
      return Result.ok(response.data);
    } catch (e) {
      return Result.error(
        Exception('Error getting dashboard data: $e'),
      );
    }
  }

  /// Lista orçamentos
  Future<Result<List<EstimateModel>>> getEstimates({
    int? limit,
    int? offset,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) queryParams['status'] = status;

      final response = await _httpService.get(
        AppUrls.estimatesBaseUrl,
        queryParameters: queryParams,
      );

      final estimates = (response.data['estimates'] as List)
          .map((estimate) => EstimateModel.fromJson(estimate))
          .toList();
      return Result.ok(estimates);
    } catch (e) {
      return Result.error(
        Exception('Error listing estimates: $e'),
      );
    }
  }

  /// Cria um novo orçamento
  Future<Result<EstimateModel>> createEstimate(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpService.post(
        AppUrls.estimatesBaseUrl,
        data: data,
      );

      final estimate = EstimateModel.fromJson(response.data);
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error creating estimate: $e'),
      );
    }
  }

  /// Obtém um orçamento específico
  Future<Result<EstimateModel>> getEstimate(String estimateId) async {
    try {
      final response = await _httpService.get(
        '${AppUrls.estimatesBaseUrl}/$estimateId',
      );
      final estimate = EstimateModel.fromJson(response.data);
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error getting estimate: $e'),
      );
    }
  }

  /// Atualiza um orçamento
  Future<Result<EstimateModel>> updateEstimate(
    String estimateId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _httpService.put(
        '${AppUrls.estimatesBaseUrl}/$estimateId',
        data: data,
      );

      final estimate = EstimateModel.fromJson(response.data);
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error updating estimate: $e'),
      );
    }
  }

  /// Remove um orçamento
  Future<Result<bool>> deleteEstimate(String estimateId) async {
    try {
      await _httpService.delete('${AppUrls.estimatesBaseUrl}/$estimateId');
      return Result.ok(true);
    } catch (e) {
      return Result.error(
        Exception('Error deleting estimate: $e'),
      );
    }
  }

  /// Atualiza o status de um orçamento
  Future<Result<EstimateModel>> updateEstimateStatus(
    String estimateId,
    String status,
  ) async {
    try {
      final response = await _httpService.patch(
        '${AppUrls.estimatesBaseUrl}/$estimateId/status',
        data: {'status': status},
      );

      final estimate = EstimateModel.fromJson(response.data);
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error updating estimate status: $e'),
      );
    }
  }

  /// Faz upload de fotos para um orçamento
  Future<Result<List<String>>> uploadPhotos(
    String estimateId,
    List<String> photoPaths,
  ) async {
    try {
      final files = await Future.wait(
        photoPaths.map((path) => MultipartFile.fromFile(path)),
      );

      final formData = FormData.fromMap({
        'photos': files,
      });

      final response = await _httpService.post(
        '${AppUrls.estimatesBaseUrl}/$estimateId/photos',
        data: formData,
      );

      final photoUrls = List<String>.from(response.data['photoUrls'] ?? []);
      return Result.ok(photoUrls);
    } catch (e) {
      return Result.error(
        Exception('Error uploading photos: $e'),
      );
    }
  }

  /// Seleciona elementos para um orçamento
  Future<Result<Map<String, dynamic>>> selectElements(
    String estimateId,
    List<String> elementIds,
  ) async {
    try {
      final response = await _httpService.post(
        '${AppUrls.estimatesBaseUrl}/$estimateId/elements',
        data: {'elementIds': elementIds},
      );

      return Result.ok(response.data);
    } catch (e) {
      return Result.error(
        Exception('Error selecting elements: $e'),
      );
    }
  }

  /// Finaliza um orçamento
  Future<Result<EstimateModel>> finalizeEstimate(String estimateId) async {
    try {
      final response = await _httpService.post(
        '${AppUrls.estimatesBaseUrl}/$estimateId/finalize',
      );

      final estimate = EstimateModel.fromJson(response.data);
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error finalizing estimate: $e'),
      );
    }
  }

  /// Envia orçamento para GHL
  Future<Result<bool>> sendToGHL(String estimateId) async {
    try {
      final response = await _httpService.post(
        '${AppUrls.estimatesBaseUrl}/$estimateId/send-to-ghl',
      );

      return Result.ok(response.data['success'] == true);
    } catch (e) {
      return Result.error(
        Exception('Error sending estimate to GHL: $e'),
      );
    }
  }

  /// Cria um novo orçamento via multipart/form-data com zonas, materiais e fotos
  Future<Result<EstimateModel>> createEstimateMultipart(
    EstimateModel estimate,
  ) async {
    try {
      final formData = await estimate.toFormData();

      final response = await _httpService.post(
        AppUrls.estimatesBaseUrl,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // O backend retorna { success: true, message: "...", data: {...} }
        final data = response.data;

        if (data is Map<String, dynamic>) {
          // Backend sempre retorna data['data'] com o estimate
          if (data['data'] is Map<String, dynamic>) {
            return Result.ok(EstimateModel.fromJson(data['data']));
          }
          // Fallback: se não tem data['data'], tenta usar data diretamente
          return Result.ok(EstimateModel.fromJson(data));
        }

        // Se data é String, pode ser uma mensagem de erro do backend
        if (data is String) {
          return Result.error(
            Exception('Backend error: $data'),
          );
        }

        return Result.error(
          Exception('Unexpected response format: ${data.runtimeType}'),
        );
      }

      return Result.error(
        Exception('Create estimate failed: ${response.statusCode}'),
      );
    } on DioException catch (e) {
      return Result.error(
        Exception('Error creating estimate (multipart): ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Exception('Unexpected error creating estimate (multipart): $e'),
      );
    }
  }
}
