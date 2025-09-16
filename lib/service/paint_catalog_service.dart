import '../model/paint_catalog/paint_catalog_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class PaintCatalogService {
  final HttpService _httpService;
  static const String _baseUrl = '/paint-catalog';

  PaintCatalogService(this._httpService);

  /// Lista marcas de tinta
  Future<Result<List<String>>> getPaintBrands() async {
    try {
      final response = await _httpService.get('$_baseUrl/brands');
      final brands = List<String>.from(response.data['brands'] ?? []);
      return Result.ok(brands);
    } catch (e) {
      return Result.error(Exception('Error listing paint brands: $e'));
    }
  }

  /// Lista marcas populares
  Future<Result<List<String>>> getPopularBrands() async {
    try {
      final response = await _httpService.get('$_baseUrl/brands/popular');
      final brands = List<String>.from(response.data['brands'] ?? []);
      return Result.ok(brands);
    } catch (e) {
      return Result.error(Exception('Error listing popular brands: $e'));
    }
  }

  /// Lista cores de uma marca específica
  Future<Result<List<PaintColor>>> getBrandColors(String brandName) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/brands/$brandName/colors',
      );
      final colors = (response.data['colors'] as List)
          .map((color) => PaintColor.fromJson(color))
          .toList();
      return Result.ok(colors);
    } catch (e) {
      return Result.error(Exception('Error listing brand colors: $e'));
    }
  }

  /// Obtém detalhes de uma cor específica
  Future<Result<PaintColor>> getColorDetails(String colorId) async {
    try {
      final response = await _httpService.get('$_baseUrl/colors/$colorId');
      final color = PaintColor.fromJson(response.data);
      return Result.ok(color);
    } catch (e) {
      return Result.error(Exception('Error getting color details: $e'));
    }
  }

  /// Busca cores por nome
  Future<Result<List<PaintColor>>> searchColors(String query) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/colors/search',
        queryParameters: {'q': query},
      );
      final colors = (response.data['colors'] as List)
          .map((color) => PaintColor.fromJson(color))
          .toList();
      return Result.ok(colors);
    } catch (e) {
      return Result.error(Exception('Error searching colors: $e'));
    }
  }

  /// Calcula necessidade de tinta para uma área
  Future<Result<Map<String, dynamic>>> calculatePaintNeeds({
    required double areaInSquareFeet,
    required String colorId,
    required int coats,
  }) async {
    try {
      final response = await _httpService.post(
        '$_baseUrl/calculate',
        data: {
          'area': areaInSquareFeet,
          'colorId': colorId,
          'coats': coats,
        },
      );

      if (response.data['success'] == true) {
        return Result.ok(response.data['calculation']);
      } else {
        return Result.error(response.data['error']);
      }
    } catch (e) {
      return Result.error(
        Exception('Error calculating paint needs: $e'),
      );
    }
  }

  /// Obtém visão geral do catálogo
  Future<Result<Map<String, dynamic>>> getCatalogOverview() async {
    try {
      final response = await _httpService.get('$_baseUrl/overview');
      return Result.ok(response.data);
    } catch (e) {
      return Result.error(Exception('Error getting catalog overview: $e'));
    }
  }

  /// Busca cores por nome (método alternativo)
  Future<Result<List<PaintColor>>> findColorsByName(String name) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/colors/find',
        queryParameters: {'name': name},
      );
      final colors = (response.data['colors'] as List)
          .map((color) => PaintColor.fromJson(color))
          .toList();
      return Result.ok(colors);
    } catch (e) {
      return Result.error(Exception('Error finding colors by name: $e'));
    }
  }

  /// Obtém cores por tipo de uso
  Future<Result<List<PaintColor>>> getColorsByUsage(String usage) async {
    try {
      final response = await _httpService.get(
        '$_baseUrl/colors/usage/$usage',
      );
      final colors = (response.data['colors'] as List)
          .map((color) => PaintColor.fromJson(color))
          .toList();
      return Result.ok(colors);
    } catch (e) {
      return Result.error(Exception('Error getting colors by usage: $e'));
    }
  }
}
