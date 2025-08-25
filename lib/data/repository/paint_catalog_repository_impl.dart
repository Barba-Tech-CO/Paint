import '../../domain/repository/paint_catalog_repository.dart';
import '../../model/paint_catalog_model.dart';
import '../../service/paint_catalog_service.dart';
import '../../utils/result/result.dart';

class PaintCatalogRepository implements IPaintCatalogRepository {
  final PaintCatalogService _paintCatalogService;

  PaintCatalogRepository({required PaintCatalogService paintCatalogService})
    : _paintCatalogService = paintCatalogService;

  @override
  Future<Result<List<String>>> getBrands() {
    return _paintCatalogService.getPaintBrands();
  }

  @override
  Future<Result<List<String>>> getPopularBrands() {
    return _paintCatalogService.getPopularBrands();
  }

  @override
  Future<Result<List<PaintColor>>> getBrandColors(String brandName) {
    return _paintCatalogService.getBrandColors(brandName);
  }

  @override
  Future<Result<PaintColor>> getColorDetails(String colorId) {
    return _paintCatalogService.getColorDetails(colorId);
  }

  @override
  Future<Result<List<PaintColor>>> searchColors(String query) {
    return _paintCatalogService.searchColors(query);
  }

  @override
  Future<Result<Map<String, dynamic>>> calculatePaintNeeds({
    required double areaInSquareMeters,
    required String colorId,
    required int coats,
  }) {
    return _paintCatalogService.calculatePaintNeeds(
      areaInSquareMeters: areaInSquareMeters,
      colorId: colorId,
      coats: coats,
    );
  }

  @override
  Future<Result<Map<String, dynamic>>> getOverview() {
    return _paintCatalogService.getCatalogOverview();
  }

  @override
  Future<Result<List<PaintColor>>> findColorsByName(String name) {
    return _paintCatalogService.findColorsByName(name);
  }

  @override
  Future<Result<List<PaintColor>>> getColorsByUsage(String usage) {
    return _paintCatalogService.getColorsByUsage(usage);
  }
}
