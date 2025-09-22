import '../../domain/repository/material_repository.dart';
import '../../model/material_models/material_model.dart';
import '../../model/material_models/material_filter.dart';
import '../../model/material_models/material_stats_model.dart';
import '../../service/material_service.dart';
import '../../utils/result/result.dart';

class MaterialRepository implements IMaterialRepository {
  final MaterialService _materialService;

  MaterialRepository({
    required MaterialService materialService,
  }) : _materialService = materialService;

  @override
  Future<Result<List<MaterialModel>>> getAllMaterials({
    int? limit,
    int? offset,
  }) async {
    // Orquestra entre cache e API baseado na disponibilidade de dados
    final hasCache = await _materialService.hasMaterialsInCache();
    final cacheCount = await _materialService.getMaterialsCount();
    final requestedEndIndex = (offset ?? 0) + (limit ?? cacheCount);
    final hasSufficientCache = hasCache && requestedEndIndex <= cacheCount;

    if (hasSufficientCache) {
      return await _materialService.getMaterialsFromCache(
        limit: limit,
        offset: offset,
      );
    }

    // Cache insuficiente, busca da API e aplica paginação
    final apiResult = await _materialService.getAllMaterialsFromApi();
    return apiResult.when(
      ok: (allMaterials) {
        if (limit != null) {
          final startIndex = offset ?? 0;
          final paginatedMaterials = allMaterials
              .skip(startIndex)
              .take(limit)
              .toList();
          return Result.ok(paginatedMaterials);
        }
        return Result.ok(allMaterials);
      },
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(
    MaterialFilter filter, {
    int? limit,
    int? offset,
  }) async {
    // Tenta buscar do cache primeiro
    final cacheResult = await _materialService.getMaterialsWithFilterFromCache(
      filter,
      limit: limit,
      offset: offset,
    );

    if (cacheResult is Ok<List<MaterialModel>> &&
        cacheResult.value.isNotEmpty) {
      return cacheResult;
    }

    // Cache não tem dados filtrados, busca da API e aplica filtros
    final apiResult = await _materialService.getAllMaterialsFromApi();
    return apiResult.when(
      ok: (allMaterials) {
        final filteredMaterials = _applyFilters(allMaterials, filter);
        if (limit != null) {
          final startIndex = offset ?? 0;
          final paginatedMaterials = filteredMaterials
              .skip(startIndex)
              .take(limit)
              .toList();
          return Result.ok(paginatedMaterials);
        }
        return Result.ok(filteredMaterials);
      },
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<MaterialModel?>> getMaterialById(String id) async {
    // Busca primeiro do cache
    final cacheResult = await _materialService.getMaterialByIdFromCache(id);
    if (cacheResult is Ok<MaterialModel?> && cacheResult.value != null) {
      return cacheResult;
    }

    // Se não encontrou no cache, busca da API
    final apiResult = await _materialService.getAllMaterialsFromApi();
    return apiResult.when(
      ok: (materials) {
        try {
          final material = materials.firstWhere(
            (material) => material.id == id,
            orElse: () => throw Exception('Material not found'),
          );
          return Result.ok(material);
        } catch (e) {
          return Result.ok(null);
        }
      },
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<MaterialStatsModel>> getMaterialStats() async {
    // Busca primeiro do cache
    final cacheResult = await _materialService.getMaterialStatsFromCache();
    if (cacheResult is Ok<MaterialStatsModel> &&
        cacheResult.value.totalMaterials > 0) {
      return cacheResult;
    }

    // Se cache vazio, busca da API e recalcula
    final apiResult = await _materialService.getAllMaterialsFromApi();
    return apiResult.when(
      ok: (materials) => _materialService.getMaterialStatsFromCache(),
      error: (error) => Result.error(error),
    );
  }

  @override
  Future<Result<List<String>>> getAvailableBrands() async {
    // Busca primeiro do cache
    final cacheResult = await _materialService.getAvailableBrandsFromCache();
    if (cacheResult is Ok<List<String>> && cacheResult.value.isNotEmpty) {
      return cacheResult;
    }

    // Se cache vazio, busca da API
    final apiResult = await _materialService.getAllMaterialsFromApi();
    return apiResult.when(
      ok: (materials) => _materialService.getAvailableBrandsFromCache(),
      error: (error) => Result.error(error),
    );
  }

  /// Aplica filtros localmente aos materiais
  List<MaterialModel> _applyFilters(
    List<MaterialModel> materials,
    MaterialFilter filter,
  ) {
    List<MaterialModel> filteredMaterials = materials;

    if (filter.type != null) {
      filteredMaterials = filteredMaterials
          .where((material) => material.type == filter.type)
          .toList();
    }

    if (filter.quality != null) {
      filteredMaterials = filteredMaterials
          .where((material) => material.quality == filter.quality)
          .toList();
    }

    if (filter.minPrice != null) {
      filteredMaterials = filteredMaterials
          .where((material) => material.price >= filter.minPrice!)
          .toList();
    }

    if (filter.maxPrice != null) {
      filteredMaterials = filteredMaterials
          .where((material) => material.price <= filter.maxPrice!)
          .toList();
    }

    if (filter.searchTerm != null && filter.searchTerm!.isNotEmpty) {
      final searchLower = filter.searchTerm!.toLowerCase();
      filteredMaterials = filteredMaterials
          .where(
            (material) =>
                material.name.toLowerCase().contains(searchLower) ||
                material.code.toLowerCase().contains(searchLower),
          )
          .toList();
    }

    return filteredMaterials;
  }
}
