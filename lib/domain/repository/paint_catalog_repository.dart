import '../../model/paint_catalog/paint_catalog_model.dart';
import '../../utils/result/result.dart';

abstract class IPaintCatalogRepository {
  /// Lista todas as marcas
  Future<Result<List<String>>> getBrands();

  /// Lista marcas populares
  Future<Result<List<String>>> getPopularBrands();

  /// Lista cores de uma marca específica
  Future<Result<List<PaintColor>>> getBrandColors(String brandName);

  /// Obtém detalhes de uma cor específica
  Future<Result<PaintColor>> getColorDetails(String colorId);

  /// Busca cores por nome
  Future<Result<List<PaintColor>>> searchColors(String query);

  /// Calcula a necessidade de tinta para uma área
  Future<Result<Map<String, dynamic>>> calculatePaintNeeds({
    required double areaInSquareFeet,
    required String colorId,
    required int coats,
  });

  /// Retorna uma visão geral do catálogo
  Future<Result<Map<String, dynamic>>> getOverview();

  /// Busca cores por nome (método alternativo)
  Future<Result<List<PaintColor>>> findColorsByName(String name);

  /// Obtém cores por tipo de uso
  Future<Result<List<PaintColor>>> getColorsByUsage(String usage);
}
