import '../../model/material_models/material_extracted_model.dart';
import '../../utils/result/result.dart';

abstract class IMaterialExtractedRepository {
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
  });

  /// Obtém marcas disponíveis dos materiais extraídos
  Future<Result<List<String>>> getAvailableBrands();

  /// Obtém categorias disponíveis dos materiais extraídos
  Future<Result<List<String>>> getAvailableCategories();

  /// Busca materiais extraídos por termo de busca
  Future<Result<MaterialExtractedResponse>> searchExtractedMaterials(
    String searchTerm, {
    int? page,
  });

  /// Filtra materiais por marca
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByBrand(
    String brand, {
    int? page,
  });

  /// Filtra materiais por ambiente
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByAmbient(
    String ambient, {
    int? page,
  });

  /// Filtra materiais por acabamento
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByFinish(
    String finish, {
    int? page,
  });

  /// Filtra materiais por qualidade
  Future<Result<MaterialExtractedResponse>> getExtractedMaterialsByQuality(
    List<String> quality, {
    int? page,
  });
}
