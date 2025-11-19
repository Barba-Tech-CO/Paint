import '../../domain/repository/material_repository.dart';
import '../../model/material_models/material_model.dart';
import '../../model/material_models/material_filter.dart';
import '../../model/material_models/material_stats_model.dart';
import '../../service/material_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class MaterialRepository implements IMaterialRepository {
  final MaterialService _materialService;
  final AppLogger _logger;

  MaterialRepository({
    required MaterialService materialService,
    required AppLogger logger,
  }) : _materialService = materialService,
       _logger = logger;

  @override
  Future<Result<List<MaterialModel>>> getAllMaterials({
    int? limit,
    int? offset,
  }) async {
    try {
      // Offline-first strategy: Always try to sync from API first
      final apiResult = await _materialService.getAllMaterialsFromApi();

      if (apiResult is Ok) {
        final allMaterials = apiResult.asOk.value;
        

        // Apply pagination to API results
        if (limit != null) {
          final startIndex = offset ?? 0;
          final paginatedMaterials = allMaterials
              .skip(startIndex)
              .take(limit)
              .toList();
          return Result.ok(paginatedMaterials);
        }
        return Result.ok(allMaterials);
      } else {
        _logger.warning(
          'MaterialRepository: API sync failed: ${apiResult.asError.error}',
        );

        // If API fails, try to get from cache
        final hasCache = await _materialService.hasMaterialsInCache();
        if (hasCache) {
          
          return await _materialService.getMaterialsFromCache(
            limit: limit,
            offset: offset,
          );
        }

        return Result.error(
          Exception('No materials available offline and API sync failed'),
        );
      }
    } catch (e) {
      _logger.error('MaterialRepository: Error getting materials: $e', e);
      return Result.error(
        Exception('Error getting materials'),
      );
    }
  }

  @override
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(
    MaterialFilter filter, {
    int? limit,
    int? offset,
  }) async {
    try {
      // Offline-first strategy: Always try to sync from API first
      final apiResult = await _materialService.getAllMaterialsFromApi();

      if (apiResult is Ok) {
        final allMaterials = apiResult.asOk.value;
        final filteredMaterials = _applyFilters(allMaterials, filter);
        

        // Apply pagination to filtered results
        if (limit != null) {
          final startIndex = offset ?? 0;
          final paginatedMaterials = filteredMaterials
              .skip(startIndex)
              .take(limit)
              .toList();
          return Result.ok(paginatedMaterials);
        }
        return Result.ok(filteredMaterials);
      } else {
        _logger.warning(
          'MaterialRepository: API sync failed: ${apiResult.asError.error}',
        );

        // If API fails, try to get filtered results from cache
        final cacheResult = await _materialService
            .getMaterialsWithFilterFromCache(
              filter,
              limit: limit,
              offset: offset,
            );

        if (cacheResult is Ok<List<MaterialModel>> &&
            cacheResult.value.isNotEmpty) {
          
          return cacheResult;
        }

        return Result.error(
          Exception(
            'No filtered materials available offline and API sync failed',
          ),
        );
      }
    } catch (e) {
      _logger.error(
        'MaterialRepository: Error getting filtered materials: $e',
        e,
      );
      return Result.error(
        Exception('Error getting filtered materials'),
      );
    }
  }

  @override
  Future<Result<MaterialModel?>> getMaterialById(String id) async {
    try {
      // Try cache first
      final cacheResult = await _materialService.getMaterialByIdFromCache(id);
      if (cacheResult is Ok<MaterialModel?> && cacheResult.value != null) {
        return cacheResult;
      }

      // Fetch directly by ID from API, cache it, and return
      final apiResult = await _materialService.getMaterialByIdFromApi(id);
      if (apiResult is Ok<MaterialModel?>) {
        return apiResult;
      }

      return Result.error(Exception('Material not found with id: $id'));
    } catch (e) {
      _logger.error('MaterialRepository: Error getting material $id: $e', e);
      return Result.error(
        Exception('Error getting material by ID'),
      );
    }
  }

  @override
  Future<Result<MaterialStatsModel>> getMaterialStats() async {
    try {
      // Offline-first strategy: Always try to sync from API first
      final apiResult = await _materialService.getAllMaterialsFromApi();

      if (apiResult is Ok) {
        
        // After syncing from API, get stats from cache
        return await _materialService.getMaterialStatsFromCache();
      } else {
        _logger.warning(
          'MaterialRepository: API sync failed: ${apiResult.asError.error}',
        );

        // If API fails, try to get stats from existing cache
        final cacheResult = await _materialService.getMaterialStatsFromCache();
        if (cacheResult is Ok<MaterialStatsModel> &&
            cacheResult.value.totalMaterials > 0) {
          
          return cacheResult;
        }

        return Result.error(
          Exception('No material stats available offline and API sync failed'),
        );
      }
    } catch (e) {
      _logger.error('MaterialRepository: Error getting material stats: $e', e);
      return Result.error(
        Exception('Error getting material stats'),
      );
    }
  }

  @override
  Future<Result<List<String>>> getAvailableBrands() async {
    try {
      // Offline-first strategy: Always try to sync from API first
      final apiResult = await _materialService.getAllMaterialsFromApi();

      if (apiResult is Ok) {
        
        // After syncing from API, get brands from cache
        return await _materialService.getAvailableBrandsFromCache();
      } else {
        _logger.warning(
          'MaterialRepository: API sync failed: ${apiResult.asError.error}',
        );

        // If API fails, try to get brands from existing cache
        final cacheResult = await _materialService
            .getAvailableBrandsFromCache();
        if (cacheResult is Ok<List<String>> && cacheResult.value.isNotEmpty) {
          
          return cacheResult;
        }

        return Result.error(
          Exception('No brands available offline and API sync failed'),
        );
      }
    } catch (e) {
      _logger.error(
        'MaterialRepository: Error getting available brands: $e',
        e,
      );
      return Result.error(
        Exception('Error getting available brands'),
      );
    }
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
