import '../model/material_models/material_extracted_model.dart';
import '../utils/result/result.dart';
import '../utils/logger/app_logger.dart';
import 'http_service.dart';

class MaterialExtractedService {
  final HttpService _httpService;
  final AppLogger _logger;
  static const String _baseUrl = '/api/materials/uploads';

  MaterialExtractedService(this._httpService, this._logger);

  /// Lista materiais extraídos com filtros
  Future<Result<MaterialExtractedResponse>> getExtractedMaterials({
    String? brand,
    String? ambient,
    String? finish,
    List<String>? quality,
    String? search,
    int? page,
    String? sortBy,
    String? sortOrder,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (brand != null) queryParams['brand'] = brand;
      if (ambient != null) queryParams['ambient'] = ambient;
      if (finish != null) queryParams['finish'] = finish;
      if (quality != null && quality.isNotEmpty) {
        for (int i = 0; i < quality.length; i++) {
          queryParams['quality[$i]'] = quality[i];
        }
      }
      if (search != null) queryParams['search'] = search;
      if (page != null) queryParams['page'] = page;
      if (sortBy != null) queryParams['sort_by'] = sortBy;
      if (sortOrder != null) queryParams['sort_order'] = sortOrder;

      _logger.info(
        '[MaterialExtractedService] Fazendo request para: $_baseUrl/extracted',
      );
      _logger.info('[MaterialExtractedService] Query params: $queryParams');

      final response = await _httpService.get(
        '$_baseUrl/extracted',
        queryParameters: queryParams,
      );

      _logger.info(
        '[MaterialExtractedService] Response status: ${response.statusCode}',
      );
      _logger.info(
        '[MaterialExtractedService] Response data type: ${response.data.runtimeType}',
      );
      _logger.info(
        '[MaterialExtractedService] Response data: ${response.data}',
      );

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      // Verifica se a resposta é um erro (como 404)
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('error')) {
        throw Exception('API Error: ${response.data['error']}');
      }

      final extractedResponse = MaterialExtractedResponse.fromJson(
        response.data,
      );

      _logger.info(
        '[MaterialExtractedService] Parsed response - success: ${extractedResponse.success}',
      );
      _logger.info(
        '[MaterialExtractedService] Materials count: ${extractedResponse.data.materials.length}',
      );

      return Result.ok(extractedResponse);
    } on Exception catch (e) {
      // Captura exceções específicas (HTTP errors, parsing errors, etc.)
      _logger.error('[MaterialExtractedService] Exception: $e');

      String errorMessage;
      if (e.toString().contains('404')) {
        errorMessage = 'Endpoint not found (404)';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error (500)';
      } else if (e.toString().contains('API Error:')) {
        errorMessage = e.toString();
      } else {
        errorMessage = 'Error loading extracted materials: $e';
      }

      return Result.error(Exception(errorMessage));
    } catch (e) {
      _logger.error('[MaterialExtractedService] General error: $e');
      return Result.error(Exception('Error loading extracted materials: $e'));
    }
  }

  /// Obtém marcas disponíveis dos materiais extraídos
  Future<Result<List<String>>> getAvailableBrands() async {
    try {
      // Busca todos os materiais para extrair as marcas únicas
      final response = await _httpService.get('$_baseUrl/extracted');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      // Verifica se a resposta é um erro
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('error')) {
        throw Exception('API Error: ${response.data['error']}');
      }

      final extractedResponse = MaterialExtractedResponse.fromJson(
        response.data,
      );

      final brands = extractedResponse.data.materials
          .where((material) => material.brand != null)
          .map((material) => material.brand!)
          .toSet()
          .toList();

      return Result.ok(brands);
    } catch (e) {
      return Result.error(Exception('Error loading available brands: $e'));
    }
  }

  /// Obtém categorias disponíveis dos materiais extraídos
  Future<Result<List<String>>> getAvailableCategories() async {
    try {
      final response = await _httpService.get('$_baseUrl/extracted');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      // Verifica se a resposta é um erro
      if (response.data is Map<String, dynamic> &&
          response.data.containsKey('error')) {
        throw Exception('API Error: ${response.data['error']}');
      }

      final extractedResponse = MaterialExtractedResponse.fromJson(
        response.data,
      );

      final categories = extractedResponse.data.materials
          .where((material) => material.category != null)
          .map((material) => material.category!)
          .toSet()
          .toList();

      return Result.ok(categories);
    } catch (e) {
      return Result.error(Exception('Error loading available categories: $e'));
    }
  }

  /// Busca materiais extraídos por termo de busca
  Future<Result<MaterialExtractedResponse>> searchExtractedMaterials(
    String searchTerm, {
    int? page,
  }) async {
    return getExtractedMaterials(
      search: searchTerm,
      page: page,
    );
  }

  /// Filtra materiais por marca
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByBrand(
    String brand, {
    int? page,
  }) async {
    return getExtractedMaterials(
      brand: brand,
      page: page,
    );
  }

  /// Filtra materiais por ambiente
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByAmbient(
    String ambient, {
    int? page,
  }) async {
    return getExtractedMaterials(
      ambient: ambient,
      page: page,
    );
  }

  /// Filtra materiais por acabamento
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByFinish(
    String finish, {
    int? page,
  }) async {
    return getExtractedMaterials(
      finish: finish,
      page: page,
    );
  }

  /// Filtra materiais por qualidade
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByQuality(
    List<String> quality, {
    int? page,
  }) async {
    return getExtractedMaterials(
      quality: quality,
      page: page,
    );
  }
}
