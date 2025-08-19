import '../../utils/result/result.dart';
import '../../model/models.dart';

abstract class IMaterialRepository {
  /// Busca todos os materiais disponíveis
  Future<Result<List<MaterialModel>>> getAllMaterials();

  /// Busca materiais com filtros aplicados
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(MaterialFilter filter);

  /// Busca material por ID
  Future<Result<MaterialModel?>> getMaterialById(String id);

  /// Busca estatísticas dos materiais
  Future<Result<MaterialStatsModel>> getMaterialStats();
}