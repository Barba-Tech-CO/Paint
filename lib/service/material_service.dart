import '../config/dependency_injection.dart';
import '../model/material_models/material_model.dart';
import '../model/material_models/material_filter.dart';
import '../model/material_models/material_price_range_model.dart';
import '../model/material_models/material_stats_model.dart';
import '../model/quotes_data/extracted_material_model.dart';
import '../utils/logger/app_logger.dart';
import '../utils/material/material_mapper.dart';
import '../utils/result/result.dart';
import 'material_database_service.dart';
import 'quote_service.dart';

class MaterialService {
  final QuoteService _quoteService;
  final MaterialDatabaseService _databaseService;
  late final AppLogger _logger;

  MaterialService(this._quoteService, this._databaseService) {
    _logger = getIt<AppLogger>();
  }

  /// Busca materiais do cache local
  Future<Result<List<MaterialModel>>> getMaterialsFromCache({
    int? limit,
    int? offset,
  }) async {
    try {
      final localMaterials = await _databaseService.getAllMaterials(
        limit: limit,
        offset: offset,
      );
      return Result.ok(localMaterials);
    } catch (e) {
      _logger.error('[MaterialService] Error getting materials from cache: $e');
      return Result.error(Exception('Failed to load materials from cache'));
    }
  }

  /// Busca todos os materiais da API
  Future<Result<List<MaterialModel>>> getAllMaterialsFromApi() async {
    try {
      final extractedResult = await _quoteService.getExtractedMaterials();

      return extractedResult.when(
        ok: (extractedResponse) async {
          if (extractedResponse.materials.isEmpty) {
            return Result.ok([]);
          }

          final materials = _convertExtractedToMaterials(
            extractedResponse.materials,
          );
          await _databaseService.upsertMaterials(materials);
          return Result.ok(materials);
        },
        error: (error) => Result.error(error),
      );
    } catch (e) {
      _logger.error('[MaterialService] Error fetching materials from API: $e');
      return Result.error(Exception('Failed to fetch materials'));
    }
  }

  /// Verifica se há materiais no cache
  Future<bool> hasMaterialsInCache() async {
    return await _databaseService.hasMaterials();
  }

  /// Obtém contagem de materiais no cache
  Future<int> getMaterialsCount() async {
    return await _databaseService.getMaterialsCount();
  }

  /// Converte ExtractedMaterialModel para MaterialModel
  List<MaterialModel> _convertExtractedToMaterials(
    List<ExtractedMaterialModel> extractedMaterials,
  ) {
    return extractedMaterials.map((extracted) {
      // Gera código da quote no formato padrão
      final quoteCode =
          'Quote #${extracted.pdfUploadId.toString().padLeft(3, '0')}';

      // Prioriza description, fallback para nome extraído do PDF ou gerado
      final materialName = extracted.description.isNotEmpty
          ? extracted.description
          : _extractMaterialNameFromPdf(extracted.pdfUpload?.originalName) ??
                _generateMaterialName(extracted);

      return MaterialModel(
        id: extracted.id.toString(),
        name: materialName,
        code: quoteCode,
        price: extracted.unitPrice,
        priceUnit: _convertUnitToDisplay(extracted.unit),
        type: MaterialMapper.mapCategoryToType(extracted.category),
        quality: MaterialMapper.mapQualityGradeToQuality(
          extracted.qualityGrade,
        ),
        description: '${extracted.brand} - ${extracted.description}',
        isAvailable: true,
      );
    }).toList();
  }

  /// Busca materiais com filtros do cache
  Future<Result<List<MaterialModel>>> getMaterialsWithFilterFromCache(
    MaterialFilter filter, {
    int? limit,
    int? offset,
  }) async {
    try {
      final filteredMaterials = await _databaseService.getMaterialsWithFilter(
        searchTerm: filter.searchTerm,
        type: filter.type?.name,
        quality: filter.quality?.name,
        minPrice: filter.minPrice,
        maxPrice: filter.maxPrice,
        limit: limit,
        offset: offset,
      );
      return Result.ok(filteredMaterials);
    } catch (e) {
      _logger.error(
        '[MaterialService] Error filtering materials from cache: $e',
      );
      return Result.error(Exception('Failed to filter materials from cache'));
    }
  }

  /// Busca material por ID do cache
  Future<Result<MaterialModel?>> getMaterialByIdFromCache(String id) async {
    try {
      final material = await _databaseService.getMaterialById(id);
      return Result.ok(material);
    } catch (e) {
      _logger.error('[MaterialService] Error searching material by ID: $e');
      return Result.error(Exception('Failed to search material'));
    }
  }

  /// Busca marcas disponíveis do cache
  Future<Result<List<String>>> getAvailableBrandsFromCache() async {
    try {
      final materials = await _databaseService.getAllMaterials();
      final brands = materials
          .map((material) => material.name.split(' - ').first)
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList();

      return Result.ok(brands);
    } catch (e) {
      _logger.error('[MaterialService] Error loading available brands: $e');
      return Result.error(Exception('Failed to load brands'));
    }
  }

  /// Busca estatísticas dos materiais do cache
  Future<Result<MaterialStatsModel>> getMaterialStatsFromCache() async {
    try {
      final materials = await _databaseService.getAllMaterials();

      if (materials.isEmpty) {
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

      final availableMaterials = materials.where((m) => m.isAvailable).length;
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
    } catch (e) {
      _logger.error('[MaterialService] Error loading material statistics: $e');
      return Result.error(Exception('Failed to load statistics'));
    }
  }

  /// Converte unidades do backend para formato de exibição
  String _convertUnitToDisplay(String unit) {
    final convertedUnit = switch (unit.toLowerCase()) {
      'gallon' => 'Gal',
      'liter' || 'litre' => 'L',
      'quart' => 'Qt',
      'pint' => 'Pt',
      'ounce' || 'oz' => 'Oz',
      'pound' || 'lb' => 'Lb',
      'kilogram' || 'kg' => 'Kg',
      'gram' || 'g' => 'G',
      'square foot' || 'sqft' || 'sq ft' => 'Sq Ft',
      'square meter' || 'sqm' || 'sq m' => 'Sq M',
      'linear foot' || 'lnft' || 'ln ft' => 'Ln Ft',
      'linear meter' || 'lnm' || 'ln m' => 'Ln M',
      'piece' || 'each' || 'ea' => 'Ea',
      'box' => 'Box',
      'case' => 'Case',
      'roll' => 'Roll',
      'sheet' => 'Sheet',
      'tube' => 'Tube',
      'can' => 'Can',
      'bottle' => 'Bottle',
      'bag' => 'Bag',
      'pack' => 'Pack',
      _ =>
        unit.toUpperCase(), // Se não encontrar correspondência, retorna a unidade original em maiúscula
    };

    return convertedUnit;
  }

  /// Tenta extrair o nome do material do nome do arquivo PDF
  String? _extractMaterialNameFromPdf(String? originalName) {
    if (originalName == null || originalName.isEmpty) return null;

    // Remove extensão .pdf
    String nameWithoutExt = originalName.replaceAll(RegExp(r'\.pdf$'), '');

    // Tenta extrair nome do produto de padrões comuns
    // Ex: "Price Quote - Quote # 7885104.pdf" -> pode conter nome do produto
    // Ex: "PM 200 ZERO EG-SHEL Quote.pdf" -> "PM 200 ZERO EG-SHEL"

    // Remove prefixos comuns
    String cleaned = nameWithoutExt
        .replaceAll(RegExp(r'^Price Quote\s*-\s*'), '')
        .replaceAll(RegExp(r'Quote\s*#\s*\d+'), '')
        .replaceAll(RegExp(r'Quote$'), '')
        .trim();

    // Se sobrou algo significativo (mais que 3 caracteres), usa
    if (cleaned.length > 3) {
      return cleaned;
    }

    return null;
  }

  /// Gera um nome de material baseado nos campos disponíveis
  String _generateMaterialName(ExtractedMaterialModel extracted) {
    // Tenta criar um nome mais descritivo baseado nos campos disponíveis
    List<String> nameParts = [];

    // Adiciona brand se disponível
    if (extracted.brand.isNotEmpty) {
      nameParts.add(extracted.brand);
    }

    // Adiciona finish se disponível
    if (extracted.finish != null && extracted.finish!.isNotEmpty) {
      nameParts.add(extracted.finish!);
    }

    // Adiciona quality grade se disponível
    if (extracted.qualityGrade != null && extracted.qualityGrade!.isNotEmpty) {
      nameParts.add(extracted.qualityGrade!);
    }

    // Adiciona category se disponível
    if (extracted.category != null && extracted.category!.isNotEmpty) {
      nameParts.add(extracted.category!);
    }

    // Se conseguiu montar algo, retorna
    if (nameParts.isNotEmpty) {
      final generatedName = nameParts.join(' ');
      return generatedName;
    }

    // Fallback para brand apenas
    return extracted.brand;
  }
}
