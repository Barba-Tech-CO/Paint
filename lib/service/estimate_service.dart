import 'package:dio/dio.dart';

import '../model/estimates/estimate_create_request.dart';
import '../model/estimates/estimate_model.dart';
import '../model/estimates/estimate_response.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class EstimateService {
  final HttpService _httpService;
  static const String _baseUrl = '/estimates';

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

  /// Cria um estimate completo com upload multipart
  Future<Result<EstimateModel>> createEstimateMultipart(
    EstimateCreateRequest request,
  ) async {
    try {
      final form = FormData();

      void addField(String key, String value) {
        form.fields.add(MapEntry(key, value));
      }

      void addNumber(String key, num value) {
        addField(key, value.toString());
      }

      Future<void> addFile(String key, String path, {String? filename}) async {
        form.files.add(
          MapEntry(
            key,
            await MultipartFile.fromFile(
              path,
              filename: filename ?? path.split('/').last,
            ),
          ),
        );
      }

      // Campos principais
      addField('contact_id', request.contactId);
      addField('project_name', request.projectName);
      addField('additional_notes', request.additionalNotes ?? '');

      for (var zi = 0; zi < request.zones.length; zi++) {
        final z = request.zones[zi];
        addField('zones[$zi][id]', z.id);
        addField('zones[$zi][name]', z.name);
        if (zi == 0 && z.zoneType != null) {
          addField(
            'zones[$zi][zone_type]',
            z.zoneType!.name,
          ); // interior|exterior|both
        }

        // data[0]
        const di = 0;
        final fd = z.floorDimensions;
        addNumber('zones[$zi][data][$di][floor_dimensions][length]', fd.length);
        addNumber('zones[$zi][data][$di][floor_dimensions][width]', fd.width);
        addNumber('zones[$zi][data][$di][floor_dimensions][height]', fd.height);
        addField('zones[$zi][data][$di][floor_dimensions][unit]', 'ft');

        // surface_areas (walls)
        for (var wi = 0; wi < z.surfaceAreas.walls.length; wi++) {
          final w = z.surfaceAreas.walls[wi];
          addField(
            'zones[$zi][data][$di][surface_areas][walls][$wi][id]',
            w.id,
          );
          if (w.width != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][walls][$wi][width]',
              w.width!,
            );
          }
          if (w.height != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][walls][$wi][height]',
              w.height!,
            );
          }
          if (w.openingsArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][walls][$wi][openings_area]',
              w.openingsArea!,
            );
          }
          if (w.netArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][walls][$wi][net_area]',
              w.netArea!,
            );
          }
          addField(
            'zones[$zi][data][$di][surface_areas][walls][$wi][unit]',
            'sqft',
          );
        }

        // surface_areas (ceiling)
        for (var ci = 0; ci < z.surfaceAreas.ceiling.length; ci++) {
          final c = z.surfaceAreas.ceiling[ci];
          addField(
            'zones[$zi][data][$di][surface_areas][ceiling][$ci][id]',
            c.id,
          );
          if (c.width != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][ceiling][$ci][width]',
              c.width!,
            );
          }
          if (c.height != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][ceiling][$ci][height]',
              c.height!,
            );
          }
          if (c.openingsArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][ceiling][$ci][openings_area]',
              c.openingsArea!,
            );
          }
          if (c.netArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][ceiling][$ci][net_area]',
              c.netArea!,
            );
          }
          addField(
            'zones[$zi][data][$di][surface_areas][ceiling][$ci][unit]',
            'sqft',
          );
        }

        // surface_areas (trim)
        for (var ti = 0; ti < z.surfaceAreas.trim.length; ti++) {
          final t = z.surfaceAreas.trim[ti];
          addField('zones[$zi][data][$di][surface_areas][trim][$ti][id]', t.id);
          if (t.width != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][trim][$ti][width]',
              t.width!,
            );
          }
          if (t.height != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][trim][$ti][height]',
              t.height!,
            );
          }
          if (t.openingsArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][trim][$ti][openings_area]',
              t.openingsArea!,
            );
          }
          if (t.netArea != null) {
            addNumber(
              'zones[$zi][data][$di][surface_areas][trim][$ti][net_area]',
              t.netArea!,
            );
          }
          addField(
            'zones[$zi][data][$di][surface_areas][trim][$ti][unit]',
            'sqft',
          );
        }

        // photos
        for (final file in z.photos) {
          await addFile('zones[$zi][data][$di][photos][]', file.path);
        }
      }

      // materials
      for (var mi = 0; mi < request.materials.length; mi++) {
        final m = request.materials[mi];
        addField('materials[$mi][id]', m.id);
        addField('materials[$mi][unit]', m.unit);
        addNumber('materials[$mi][quantity]', m.quantity);
        addNumber('materials[$mi][unit_price]', m.unitPrice);
        if (m.name != null) {
          addField('materials[$mi][name]', m.name!);
        }
        if (m.description != null) {
          addField('materials[$mi][description]', m.description!);
        }
      }

      // totals
      addNumber('totals[materials_cost]', request.totals.materialsCost);
      addNumber('totals[grand_total]', request.totals.grandTotal);
      if (request.totals.laborCost != null) {
        addNumber('totals[labor_cost]', request.totals.laborCost!);
      }
      if (request.totals.additionalCosts != null) {
        addNumber('totals[additional_costs]', request.totals.additionalCosts!);
      }

      final response = await _httpService.post(
        _baseUrl, // apenas _baseUrl pois já aponta para /estimates
        data: form,
      );

      final estimate = EstimateResponse.fromJson(
        response.data['data'],
      ).toEstimateModel();
      return Result.ok(estimate);
    } catch (e) {
      return Result.error(
        Exception('Error creating estimate with multipart: $e'),
      );
    }
  }
}
