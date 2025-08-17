import '../../domain/repository/paint_catalog_repository.dart';
import '../../model/paint_catalog_model.dart';
import '../../service/paint_catalog_service.dart';
import '../../utils/result/result.dart';

class PaintCatalogRepository implements IPaintCatalogRepository {
  final PaintCatalogService _paintCatalogService;

  PaintCatalogRepository({required PaintCatalogService paintCatalogService}) 
    : _paintCatalogService = paintCatalogService;

  @override
  Future<Result<List<PaintBrand>>> getBrands() {
    return _paintCatalogService.getBrands();
  }

  @override
  Future<Result<List<PaintBrand>>> getPopularBrands() {
    return _paintCatalogService.getPopularBrands();
  }

  @override
  Future<Result<List<PaintColor>>> getBrandColors(
    String brandKey, {
    String? usage,
  }) {
    return _paintCatalogService.getBrandColors(brandKey, usage: usage);
  }

  @override
  Future<Result<ColorDetail>> getColorDetail(
    String brandKey,
    String colorKey,
    String usage,
  ) {
    return _paintCatalogService.getColorDetail(brandKey, colorKey, usage);
  }

  @override
  Future<Result<PaintSearchResult>> searchColors({
    String? query,
    String? brand,
    int? limit,
    int? offset,
  }) {
    return _paintCatalogService.searchColors(
      query: query,
      brand: brand,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<Result<PaintCalculation>> calculatePaintNeeds({
    required String brandKey,
    required String colorKey,
    required String usage,
    required double area,
  }) {
    return _paintCatalogService.calculatePaintNeeds(
      brandKey: brandKey,
      colorKey: colorKey,
      usage: usage,
      area: area,
    );
  }

  @override
  Future<Result<CatalogOverview>> getOverview() {
    return _paintCatalogService.getOverview();
  }

  @override
  Future<Result<List<PaintColor>>> searchColorsByName(String searchTerm) {
    return _paintCatalogService.searchColorsByName(searchTerm);
  }

  @override
  Future<Result<List<PaintColor>>> getColorsByUsage(
    String brandKey,
    String usage,
  ) {
    return _paintCatalogService.getColorsByUsage(brandKey, usage);
  }
}