import '../../domain/repository/material_extracted_repository.dart';
import '../../model/material_models/material_extracted_model.dart';
import '../../service/material_extracted_service.dart';
import '../../utils/result/result.dart';

class MaterialExtractedRepository implements IMaterialExtractedRepository {
  final MaterialExtractedService _materialExtractedService;

  MaterialExtractedRepository({
    required MaterialExtractedService materialExtractedService,
  }) : _materialExtractedService = materialExtractedService;

  @override
  Future<Result<MaterialExtractedResponse>> getExtractedMaterials({
    String? brand,
    String? ambient,
    String? finish,
    List<String>? quality,
    String? search,
    int? page,
    String? sortBy,
    String? sortOrder,
  }) {
    return _materialExtractedService.getExtractedMaterials(
      brand: brand,
      ambient: ambient,
      finish: finish,
      quality: quality,
      search: search,
      page: page,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  @override
  Future<Result<List<String>>> getAvailableBrands() {
    return _materialExtractedService.getAvailableBrands();
  }

  @override
  Future<Result<List<String>>> getAvailableCategories() {
    return _materialExtractedService.getAvailableCategories();
  }

  @override
  Future<Result<MaterialExtractedResponse>> searchExtractedMaterials(
    String searchTerm, {
    int? page,
  }) {
    return _materialExtractedService.searchExtractedMaterials(
      searchTerm,
      page: page,
    );
  }

  @override
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByBrand(
    String brand, {
    int? page,
  }) {
    return _materialExtractedService.getExtractedMaterialsByBrand(
      brand,
      page: page,
    );
  }

  @override
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByAmbient(
    String ambient, {
    int? page,
  }) {
    return _materialExtractedService.getExtractedMaterialsByAmbient(
      ambient,
      page: page,
    );
  }

  @override
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByFinish(
    String finish, {
    int? page,
  }) {
    return _materialExtractedService.getExtractedMaterialsByFinish(
      finish,
      page: page,
    );
  }

  @override
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByQuality(
    List<String> quality, {
    int? page,
  }) {
    return _materialExtractedService.getExtractedMaterialsByQuality(
      quality,
      page: page,
    );
  }
}
