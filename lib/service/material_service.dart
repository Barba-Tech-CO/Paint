import '../model/material_models/material_model.dart';
import '../model/material_models/material_stats_model.dart';
import '../model/material_models/material_price_range_model.dart';
import '../utils/material/material_mapper.dart';
import '../utils/result/result.dart';
import 'quote_service.dart';

class MaterialService {
  final QuoteService _quoteService;

  MaterialService(this._quoteService);

  // // Mock data para simular a API (fallback quando não há materiais extraídos)
  // static final List<MaterialModel> _mockMaterials = [
  //   MaterialModel(
  //     id: '001',
  //     name: 'PM 200 ZERO EG-SHEL',
  //     code: 'Quote #003',
  //     price: 52.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.economic,
  //     description: 'High-quality interior paint with zero VOC',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '002',
  //     name: 'SW ProClassic Interior',
  //     code: 'Quote #004',
  //     price: 58.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.standard,
  //     description: 'Premium interior paint with excellent coverage',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '003',
  //     name: 'Behr Premium Plus Ultra',
  //     code: 'Quote #005',
  //     price: 45.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.economic,
  //     description: 'One-coat coverage interior paint',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '004',
  //     name: 'BM Advance Interior',
  //     code: 'Quote #006',
  //     price: 72.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.premium,
  //     description: 'Alkyd paint with latex cleanup',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '005',
  //     name: 'SW SuperPaint Exterior',
  //     code: 'Quote #007',
  //     price: 62.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.exterior,
  //     quality: MaterialQuality.standard,

  //     description: 'All-weather exterior paint',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '006',
  //     name: 'Behr Marquee Exterior',
  //     code: 'Quote #008',
  //     price: 55.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.exterior,
  //     quality: MaterialQuality.high,
  //     description: 'One-coat hide guaranteed exterior paint',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '007',
  //     name: 'BM Aura Interior',
  //     code: 'Quote #009',
  //     price: 89.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.premium,
  //     description: 'The ultimate luxury interior paint',
  //     isAvailable: true,
  //   ),
  //   MaterialModel(
  //     id: '008',
  //     name: 'SW Emerald Interior',
  //     code: 'Quote #010',
  //     price: 82.99,
  //     priceUnit: 'Gal',
  //     type: MaterialType.interior,
  //     quality: MaterialQuality.premium,

  //     description: 'Advanced stain-blocking technology',
  //     isAvailable: true,
  //   ),
  // ];

  /// Busca todos os materiais disponíveis
  Future<Result<List<MaterialModel>>> getAllMaterials() async {
    try {
      // Busca materiais extraídos da API
      final extractedResult = await _quoteService.getExtractedMaterials();

      return extractedResult.when(
        ok: (extractedResponse) {
          if (extractedResponse.materials.isNotEmpty) {
            // Converte ExtractedMaterialModel para MaterialModel
            final materials = extractedResponse.materials.map((extracted) {
              return MaterialModel(
                id: extracted.id.toString(),
                name: extracted.description,
                code: 'PDF #${extracted.pdfUploadId}',
                price: extracted.unitPrice,
                priceUnit: extracted.unit,
                type: MaterialMapper.mapCategoryToType(extracted.category),
                quality: MaterialMapper.mapQualityGradeToQuality(
                  extracted.qualityGrade,
                ),
                description: '${extracted.brand} - ${extracted.description}',
                isAvailable: true,
              );
            }).toList();

            return Result.ok(materials);
          } else {
            // Se não há materiais extraídos, retorna lista vazia
            return Result.ok(<MaterialModel>[]);
          }
        },
        error: (error) {
          // Em caso de erro, retorna lista vazia
          return Result.ok(<MaterialModel>[]);
        },
      );
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
      // Primeiro busca todos os materiais (extraídos ou mock)
      final allMaterialsResult = await getAllMaterials();

      return allMaterialsResult.when(
        ok: (allMaterials) {
          List<MaterialModel> filteredMaterials = allMaterials;

          // Aplica filtros
          if (filter.type != null) {
            filteredMaterials = filteredMaterials
                .where(
                  (material) => material.type == filter.type,
                )
                .toList();
          }

          if (filter.quality != null) {
            filteredMaterials = filteredMaterials
                .where(
                  (material) => material.quality == filter.quality,
                )
                .toList();
          }

          if (filter.minPrice != null) {
            filteredMaterials = filteredMaterials
                .where(
                  (material) => material.price >= filter.minPrice!,
                )
                .toList();
          }

          if (filter.maxPrice != null) {
            filteredMaterials = filteredMaterials
                .where(
                  (material) => material.price <= filter.maxPrice!,
                )
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
        },
        error: (error) {
          return Result.error(error);
        },
      );
    } catch (e) {
      return Result.error(
        Exception('Error filtering materials: $e'),
      );
    }
  }

  /// Busca material por ID
  Future<Result<MaterialModel?>> getMaterialById(String id) async {
    try {
      // Busca todos os materiais e filtra por ID
      final allMaterialsResult = await getAllMaterials();

      return allMaterialsResult.when(
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
        error: (error) {
          return Result.error(error);
        },
      );
    } catch (e) {
      return Result.error(
        Exception('Error searching material: $e'),
      );
    }
  }

  /// Busca marcas disponíveis
  Future<Result<List<String>>> getAvailableBrands() async {
    try {
      // Busca todos os materiais para extrair marcas únicas
      final allMaterialsResult = await getAllMaterials();

      return allMaterialsResult.when(
        ok: (materials) {
          // Extrai marcas únicas dos materiais
          final brands = materials
              .map((material) => material.name.split(' - ').first)
              .where((brand) => brand.isNotEmpty)
              .toSet()
              .toList();

          return Result.ok(brands);
        },
        error: (error) {
          return Result.error(error);
        },
      );
    } catch (e) {
      return Result.error(
        Exception('Error loading available brands: $e'),
      );
    }
  }

  /// Busca estatísticas dos materiais
  Future<Result<MaterialStatsModel>> getMaterialStats() async {
    try {
      // Busca todos os materiais para calcular estatísticas
      final allMaterialsResult = await getAllMaterials();

      return allMaterialsResult.when(
        ok: (materials) {
          if (materials.isEmpty) {
            // Se não há materiais, retorna estatísticas vazias
            return Result.ok(
              MaterialStatsModel(
                totalMaterials: 0,
                availableMaterials: 0,
                averagePrice: 0.0,
                priceRange: MaterialPriceRangeModel(
                  min: 0.0,
                  max: 0.0,
                ),
              ),
            );
          }

          final availableMaterials = materials
              .where((m) => m.isAvailable)
              .length;
          final totalPrice = materials.fold<double>(
            0,
            (sum, material) => sum + material.price,
          );
          final averagePrice = totalPrice / materials.length;

          final prices = materials.map((m) => m.price).toList();
          final minPrice = prices.reduce((a, b) => a < b ? a : b);
          final maxPrice = prices.reduce((a, b) => a > b ? a : b);

          final stats = MaterialStatsModel(
            totalMaterials: materials.length,
            availableMaterials: availableMaterials,
            averagePrice: averagePrice,
            priceRange: MaterialPriceRangeModel(
              min: minPrice,
              max: maxPrice,
            ),
          );

          return Result.ok(stats);
        },
        error: (error) {
          return Result.error(error);
        },
      );
    } catch (e) {
      return Result.error(
        Exception('Error loading material statistics: $e'),
      );
    }
  }
}
