import '../utils/result/result.dart';
import '../model/models.dart';

class MaterialService {
  // Mock data para simular a API
  static final List<MaterialModel> _mockMaterials = [
    MaterialModel(
      id: '001',
      name: 'PM 200 ZERO EG-SHEL',
      code: 'Quote #003',
      price: 52.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.economic,
      description: 'High-quality interior paint with zero VOC',
      isAvailable: true,
    ),
    MaterialModel(
      id: '002',
      name: 'SW ProClassic Interior',
      code: 'Quote #004',
      price: 58.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.standard,
      description: 'Premium interior paint with excellent coverage',
      isAvailable: true,
    ),
    MaterialModel(
      id: '003',
      name: 'Behr Premium Plus Ultra',
      code: 'Quote #005',
      price: 45.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.economic,
      description: 'One-coat coverage interior paint',
      isAvailable: true,
    ),
    MaterialModel(
      id: '004',
      name: 'BM Advance Interior',
      code: 'Quote #006',
      price: 72.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.premium,
      description: 'Alkyd paint with latex cleanup',
      isAvailable: true,
    ),
    MaterialModel(
      id: '005',
      name: 'SW SuperPaint Exterior',
      code: 'Quote #007',
      price: 62.99,
      priceUnit: 'Gal',
      type: MaterialType.exterior,
      quality: MaterialQuality.standard,

      description: 'All-weather exterior paint',
      isAvailable: true,
    ),
    MaterialModel(
      id: '006',
      name: 'Behr Marquee Exterior',
      code: 'Quote #008',
      price: 55.99,
      priceUnit: 'Gal',
      type: MaterialType.exterior,
      quality: MaterialQuality.high,
      description: 'One-coat hide guaranteed exterior paint',
      isAvailable: true,
    ),
    MaterialModel(
      id: '007',
      name: 'BM Aura Interior',
      code: 'Quote #009',
      price: 89.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.premium,
      description: 'The ultimate luxury interior paint',
      isAvailable: true,
    ),
    MaterialModel(
      id: '008',
      name: 'SW Emerald Interior',
      code: 'Quote #010',
      price: 82.99,
      priceUnit: 'Gal',
      type: MaterialType.interior,
      quality: MaterialQuality.premium,

      description: 'Advanced stain-blocking technology',
      isAvailable: true,
    ),
  ];

  /// Busca todos os materiais disponíveis
  Future<Result<List<MaterialModel>>> getAllMaterials() async {
    try {
      // Simula delay da API
      await Future.delayed(const Duration(milliseconds: 800));
      return Result.ok(_mockMaterials);
    } catch (e) {
      return Result.error(
        Exception('Error loading materials: $e'),
      );
    }
  }

  /// Busca materiais com filtros aplicados
  Future<Result<List<MaterialModel>>> getMaterialsWithFilter(
    MaterialFilter filter,
  ) async {
    try {
      // Simula delay da API
      await Future.delayed(const Duration(milliseconds: 600));

      List<MaterialModel> filteredMaterials = _mockMaterials;

      // Aplica filtros

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

      return Result.ok(filteredMaterials);
    } catch (e) {
      return Result.error(
        Exception('Error filtering materials: $e'),
      );
    }
  }

  /// Busca material por ID
  Future<Result<MaterialModel?>> getMaterialById(String id) async {
    try {
      // Simula delay da API
      await Future.delayed(const Duration(milliseconds: 300));

      final material = _mockMaterials.firstWhere(
        (material) => material.id == id,
        orElse: () => throw Exception('Material not found'),
      );

      return Result.ok(material);
    } catch (e) {
      return Result.error(
        Exception('Error searching material: $e'),
      );
    }
  }

  /// Busca marcas disponíveis

  /// Busca estatísticas dos materiais
  Future<Result<MaterialStatsModel>> getMaterialStats() async {
    try {
      // Simula delay da API
      await Future.delayed(const Duration(milliseconds: 400));

      final stats = MaterialStatsModel(
        totalMaterials: _mockMaterials.length,
        availableMaterials: _mockMaterials.where((m) => m.isAvailable).length,

        averagePrice:
            _mockMaterials.fold<double>(
              0,
              (sum, material) => sum + material.price,
            ) /
            _mockMaterials.length,
        priceRange: MaterialPriceRangeModel(
          min: _mockMaterials
              .map((m) => m.price)
              .reduce((a, b) => a < b ? a : b),
          max: _mockMaterials
              .map((m) => m.price)
              .reduce((a, b) => a > b ? a : b),
        ),
      );

      return Result.ok(stats);
    } catch (e) {
      return Result.error(
        Exception('Error loading material statistics: $e'),
      );
    }
  }
}
