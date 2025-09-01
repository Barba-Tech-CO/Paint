import 'package:dio/dio.dart';

import '../model/models.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class EstimateService {
  final HttpService _httpService;
  static const String _baseUrl = '/paint-pro';

  EstimateService(this._httpService);

  /// Obtém dados do dashboard
  Future<Result<Map<String, dynamic>>> getDashboardData() async {
    try {
      final response = await _httpService.get('$_baseUrl/dashboard');
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
        '$_baseUrl/estimates',
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
        '$_baseUrl/estimates',
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
        '$_baseUrl/estimates/$estimateId',
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
        '$_baseUrl/estimates/$estimateId',
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
      await _httpService.delete('$_baseUrl/estimates/$estimateId');
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
        '$_baseUrl/estimates/$estimateId/status',
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
      final formData = FormData.fromMap({
        'photos': photoPaths
            .map((path) => MultipartFile.fromFile(path))
            .toList(),
      });

      final response = await _httpService.post(
        '$_baseUrl/estimates/$estimateId/photos',
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
        '$_baseUrl/estimates/$estimateId/elements',
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
        '$_baseUrl/estimates/$estimateId/finalize',
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
        '$_baseUrl/estimates/$estimateId/send-to-ghl',
      );

      return Result.ok(response.data['success'] == true);
    } catch (e) {
      return Result.error(
        Exception('Error sending estimate to GHL: $e'),
      );
    }
  }
}
