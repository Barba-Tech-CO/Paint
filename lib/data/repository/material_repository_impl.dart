import '../../domain/repository/material_repository.dart';
import '../../model/models.dart';
import '../../service/material_service.dart';
import '../../utils/result/result.dart';

class MaterialRepository implements IMaterialRepository {
  final MaterialService _materialService;

  MaterialRepository({
    required MaterialService materialService,
  }) : _materialService = materialService;

  @override
  Future<Result<List<MaterialModel>>> getAllMaterials() {
    return _materialService.getAllMaterials();
  }

  @override
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(
    MaterialFilter filter,
  ) {
    return _materialService.getMaterialsWithFilter(filter);
  }

  @override
  Future<Result<MaterialModel?>> getMaterialById(String id) {
    return _materialService.getMaterialById(id);
  }

  @override
  Future<Result<MaterialStatsModel>> getMaterialStats() {
    return _materialService.getMaterialStats();
  }

  @override
  Future<Result<List<String>>> getAvailableBrands() {
    return _materialService.getAvailableBrands();
  }
}
