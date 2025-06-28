import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/result/result.dart';
import '../model/estimate_model.dart';
import 'http_service.dart';

class EstimateService {
  final HttpService _httpService;
  static const String _baseUrl = '/api/paint-pro';

  EstimateService(this._httpService);

  /// Obtém dados do dashboard
  Future<Result<DashboardResponse>> getDashboard() async {
    try {
      final response = await _httpService.get('$_baseUrl/estimates/dashboard');
      final dashboardResponse = DashboardResponse.fromJson(response.data);
      return Result.ok(dashboardResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao obter dados do dashboard: $e'));
    }
  }

  /// Lista orçamentos com filtros e paginação
  Future<Result<EstimateListResponse>> getEstimates({
    int? limit,
    int? offset,
    EstimateStatus? status,
    ProjectType? projectType,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;
      if (status != null) queryParams['status'] = status.name;
      if (projectType != null) queryParams['project_type'] = projectType.name;

      final response = await _httpService.get(
        '$_baseUrl/estimates',
        queryParameters: queryParams,
      );

      final estimateListResponse = EstimateListResponse.fromJson(response.data);
      return Result.ok(estimateListResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao listar orçamentos: $e'));
    }
  }

  /// Cria um novo orçamento
  Future<Result<EstimateResponse>> createEstimate({
    required String projectName,
    required String clientName,
    required ProjectType projectType,
  }) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/estimates',
        data: {
          'project_name': projectName,
          'client_name': clientName,
          'project_type': projectType.name,
        },
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao criar orçamento: $e'));
    }
  }

  /// Obtém detalhes de um orçamento
  Future<Result<EstimateResponse>> getEstimate(String estimateId) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/estimates/$estimateId',
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao obter orçamento: $e'));
    }
  }

  /// Atualiza um orçamento
  Future<Result<EstimateResponse>> updateEstimate(
    String estimateId, {
    String? projectName,
    String? clientName,
    ProjectType? projectType,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (projectName != null) updateData['project_name'] = projectName;
      if (clientName != null) updateData['client_name'] = clientName;
      if (projectType != null) updateData['project_type'] = projectType.name;

      final response = await _httpService.put(
        '$_baseUrl/estimates/$estimateId',
        data: updateData,
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar orçamento: $e'));
    }
  }

  /// Remove um orçamento
  Future<Result<bool>> deleteEstimate(String estimateId) async {
    try {
      await _httpService.delete('$_baseUrl/estimates/$estimateId');
      return Result.ok(true);
    } catch (e) {
      return Result.error(Exception('Erro ao remover orçamento: $e'));
    }
  }

  /// Atualiza o status de um orçamento
  Future<Result<EstimateResponse>> updateEstimateStatus(
    String estimateId,
    EstimateStatus status,
  ) async {
    try {
      final response = await _httpService.patch(
        '$_baseUrl/estimates/$estimateId/status',
        data: {'status': status.name},
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(
        Exception('Erro ao atualizar status do orçamento: $e'),
      );
    }
  }

  /// Upload de fotos para um orçamento
  Future<Result<EstimateResponse>> uploadPhotos(
    String estimateId,
    List<File> photos,
  ) async {
    try {
      final formData = FormData();

      for (int i = 0; i < photos.length; i++) {
        formData.files.add(
          MapEntry(
            'photos[$i]',
            await MultipartFile.fromFile(photos[i].path),
          ),
        );
      }

      final response = await _httpService.post(
        '$_baseUrl/estimates/$estimateId/photos',
        data: formData,
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao fazer upload das fotos: $e'));
    }
  }

  /// Seleciona tintas e calcula custos
  Future<Result<EstimateResponse>> selectElements(
    String estimateId, {
    required bool useCatalog,
    required String brandKey,
    required String colorKey,
    required String usage,
    required String sizeKey,
  }) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/estimates/$estimateId/select-elements',
        data: {
          'use_catalog': useCatalog,
          'brand_key': brandKey,
          'color_key': colorKey,
          'usage': usage,
          'size_key': sizeKey,
        },
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao selecionar elementos: $e'));
    }
  }

  /// Finaliza o orçamento
  Future<Result<EstimateResponse>> completeEstimate(String estimateId) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/estimates/$estimateId/complete',
      );

      final estimateResponse = EstimateResponse.fromJson(response.data);
      return Result.ok(estimateResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao finalizar orçamento: $e'));
    }
  }

  /// Envia o orçamento para o GHL
  Future<Result<bool>> sendToGHL(String estimateId) async {
    try {
      await _httpService.post('$_baseUrl/estimates/$estimateId/send-to-ghl');
      return Result.ok(true);
    } catch (e) {
      return Result.error(Exception('Erro ao enviar orçamento para GHL: $e'));
    }
  }
}
