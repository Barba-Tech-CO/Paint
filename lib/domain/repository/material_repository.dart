import '../../model/material_models/material_model.dart';
import '../../model/material_models/material_stats_model.dart';
import '../../utils/result/result.dart';

abstract class IMaterialRepository {
  /// Busca todos os materiais disponíveis
  Future<Result<List<MaterialModel>>> getAllMaterials({
    int? limit,
    int? offset,
  });

  /// Busca materiais com filtros aplicados
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(
    MaterialFilter filter, {
    int? limit,
    int? offset,
  });

  /// Busca material por ID
  Future<Result<MaterialModel?>> getMaterialById(String id);

  /// Busca estatísticas dos materiais
  Future<Result<MaterialStatsModel>> getMaterialStats();

  /// Busca marcas disponíveis
  Future<Result<List<String>>> getAvailableBrands();
}
