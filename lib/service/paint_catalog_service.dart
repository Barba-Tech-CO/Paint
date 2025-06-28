import '../utils/result/result.dart';
import '../model/paint_catalog_model.dart';
import 'http_service.dart';

class PaintCatalogService {
  final HttpService _httpService;
  static const String _baseUrl = '/api/paint-catalog';

  PaintCatalogService(this._httpService);

  /// Lista todas as marcas
  Future<Result<List<PaintBrand>>> getBrands() async {
    try {
      final response = await _httpService.get('$_baseUrl/brands');
      final List<dynamic> brandsList = response.data;
      final brands = brandsList
          .map((brand) => PaintBrand.fromJson(brand))
          .toList();
      return Result.ok(brands);
    } catch (e) {
      return Result.error(Exception('Erro ao listar marcas: $e'));
    }
  }

  /// Lista marcas populares
  Future<Result<List<PaintBrand>>> getPopularBrands() async {
    try {
      final response = await _httpService.get('$_baseUrl/brands/popular');
      final List<dynamic> brandsList = response.data;
      final brands = brandsList
          .map((brand) => PaintBrand.fromJson(brand))
          .toList();
      return Result.ok(brands);
    } catch (e) {
      return Result.error(Exception('Erro ao listar marcas populares: $e'));
    }
  }

  /// Lista cores de uma marca
  Future<Result<List<PaintColor>>> getBrandColors(
    String brandKey, {
    String? usage,
  }) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/brands/$brandKey/colors',
        queryParameters: usage != null ? {'usage': usage} : null,
      );

      final List<dynamic> colorsList = response.data;
      final colors = colorsList
          .map((color) => PaintColor.fromJson(color))
          .toList();
      return Result.ok(colors);
    } catch (e) {
      return Result.error(Exception('Erro ao listar cores da marca: $e'));
    }
  }

  /// Obtém detalhes de uma cor específica
  Future<Result<ColorDetail>> getColorDetail(
    String brandKey,
    String colorKey,
    String usage,
  ) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/brands/$brandKey/colors/$colorKey/$usage',
      );

      final colorDetail = ColorDetail.fromJson(response.data);
      return Result.ok(colorDetail);
    } catch (e) {
      return Result.error(Exception('Erro ao obter detalhes da cor: $e'));
    }
  }

  /// Busca em todas as cores e marcas
  Future<Result<PaintSearchResult>> searchColors({
    String? query,
    String? brand,
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (query != null) queryParams['q'] = query;
      if (brand != null) queryParams['brand'] = brand;
      if (limit != null) queryParams['limit'] = limit;
      if (offset != null) queryParams['offset'] = offset;

      final response = await _httpService.get(
        '$_baseUrl/search',
        queryParameters: queryParams,
      );

      final searchResult = PaintSearchResult.fromJson(response.data);
      return Result.ok(searchResult);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar cores: $e'));
    }
  }

  /// Calcula a necessidade de tinta para uma área
  Future<Result<PaintCalculation>> calculatePaintNeeds({
    required String brandKey,
    required String colorKey,
    required String usage,
    required double area,
  }) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/calculate',
        data: {
          'brand_key': brandKey,
          'color_key': colorKey,
          'usage': usage,
          'area': area,
        },
      );

      final calculation = PaintCalculation.fromJson(response.data);
      return Result.ok(calculation);
    } catch (e) {
      return Result.error(
        Exception('Erro ao calcular necessidade de tinta: $e'),
      );
    }
  }

  /// Retorna uma visão geral do catálogo
  Future<Result<CatalogOverview>> getOverview() async {
    try {
      final response = await _httpService.get('$_baseUrl/overview');
      final overview = CatalogOverview.fromJson(response.data);
      return Result.ok(overview);
    } catch (e) {
      return Result.error(
        Exception('Erro ao obter visão geral do catálogo: $e'),
      );
    }
  }

  /// Busca cores por nome ou código
  Future<Result<List<PaintColor>>> searchColorsByName(String searchTerm) async {
    try {
      final result = await searchColors(query: searchTerm);
      if (result is Ok) {
        return Result.ok(result.asOk.value.colors);
      }
      return Result.error(result.asError.error);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar cores por nome: $e'));
    }
  }

  /// Obtém cores de uma marca filtradas por uso
  Future<Result<List<PaintColor>>> getColorsByUsage(
    String brandKey,
    String usage,
  ) async {
    try {
      return await getBrandColors(brandKey, usage: usage);
    } catch (e) {
      return Result.error(Exception('Erro ao obter cores por uso: $e'));
    }
  }
}
