import '../../model/paint_catalog_model.dart';
import '../../utils/result/result.dart';

abstract class IPaintCatalogRepository {
  /// Lista todas as marcas
  Future<Result<List<PaintBrand>>> getBrands();

  /// Lista marcas populares
  Future<Result<List<PaintBrand>>> getPopularBrands();

  /// Lista cores de uma marca
  Future<Result<List<PaintColor>>> getBrandColors(
    String brandKey, {
    String? usage,
  });

  /// Obtém detalhes de uma cor específica
  Future<Result<ColorDetail>> getColorDetail(
    String brandKey,
    String colorKey,
    String usage,
  );

  /// Busca em todas as cores e marcas
  Future<Result<PaintSearchResult>> searchColors({
    String? query,
    String? brand,
    int? limit,
    int? offset,
  });

  /// Calcula a necessidade de tinta para uma área
  Future<Result<PaintCalculation>> calculatePaintNeeds({
    required String brandKey,
    required String colorKey,
    required String usage,
    required double area,
  });

  /// Retorna uma visão geral do catálogo
  Future<Result<CatalogOverview>> getOverview();

  /// Busca cores por nome ou código
  Future<Result<List<PaintColor>>> searchColorsByName(String searchTerm);

  /// Obtém cores de uma marca filtradas por uso
  Future<Result<List<PaintColor>>> getColorsByUsage(
    String brandKey,
    String usage,
  );
}