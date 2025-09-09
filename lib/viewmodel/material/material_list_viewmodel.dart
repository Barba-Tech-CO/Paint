import 'package:flutter/foundation.dart';
import '../../model/models.dart';
import '../../domain/repository/material_repository.dart';
import '../../domain/repository/material_extracted_repository.dart';

class MaterialListViewModel extends ChangeNotifier {
  final IMaterialRepository _materialRepository;
  final IMaterialExtractedRepository _materialExtractedRepository;
  final List<MaterialModel> _selectedMaterials = [];
  final List<String> _availableBrands = [];
  List<MaterialModel> _materials = [];
  List<dynamic> _rawExtractedMaterials = []; // Para acessar dados da API

  MaterialFilter _currentFilter = MaterialFilter();
  MaterialStatsModel? _stats;
  bool _isLoading = false;
  String? _error;

  MaterialListViewModel(
    this._materialRepository,
    this._materialExtractedRepository,
  );

  // Getters
  List<MaterialModel> get materials => _materials;
  List<String> get availableBrands => _availableBrands;
  MaterialFilter get currentFilter => _currentFilter;
  MaterialStatsModel? get stats => _stats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MaterialModel> get selectedMaterials => _selectedMaterials;
  int get selectedCount => _selectedMaterials.length;
  bool get hasFilters => _currentFilter.hasFilters;

  /// Carrega todos os materiais
  Future<void> loadMaterials() async {
    _setLoading(true);
    _clearError();

    try {
      // Usando a nova API de materiais extraídos
      final result = await _materialExtractedRepository.getExtractedMaterials(
        page: 1,
      );
      result.when(
        ok: (response) {
          print('[MaterialListViewModel] API Response received successfully');
          print(
            '[MaterialListViewModel] Materials count: ${response.data.materials.length}',
          );

          // Armazena os dados brutos e converte para MaterialModel
          _rawExtractedMaterials = response.data.materials;
          _materials = _convertToMaterialModels(response.data.materials);

          // Se a API retornar array vazio, carrega dados de fallback
          if (_materials.isEmpty) {
            print(
              '[MaterialListViewModel] API returned empty materials, loading fallback data',
            );
            _setError(
              'Nenhum material encontrado na API. Mostrando dados de exemplo...',
            );
            _loadFallbackMaterials();
          } else {
            // Extrai marcas disponíveis
            _updateAvailableBrands();
          }

          notifyListeners();
        },
        error: (error) {
          print('Erro na API: $error');

          // Se for erro 404, significa que endpoint não existe ou está mal configurado
          if (error.toString().contains('404') ||
              error.toString().contains('Not Found')) {
            _setError(
              'Endpoint não encontrado. Carregando dados de exemplo...',
            );
            _loadFallbackMaterials();
          }
          // Se for erro 502 ou similar, tenta fallback para dados locais
          else if (error.toString().contains('502') ||
              error.toString().contains('Server Error') ||
              error.toString().contains('Bad Gateway')) {
            _setError('Servidor indisponível. Usando dados em cache...');
            _loadFallbackMaterials();
          } else {
            _setError('Erro ao carregar materiais: ${error.toString()}');
            // Para outros erros também carrega fallback
            _loadFallbackMaterials();
          }
        },
      );
    } catch (e) {
      print('Exceção durante carregamento: $e');
      _setError('Erro inesperado ao carregar materiais: $e');
      // Tenta carregar dados de fallback
      _loadFallbackMaterials();
    } finally {
      _setLoading(false);
    }
  }

  /// Aplica filtros aos materiais
  Future<void> applyFilter(MaterialFilter filter) async {
    _setLoading(true);
    _clearError();
    _currentFilter = filter;

    try {
      // Converte MaterialFilter para os parâmetros da nova API
      final result = await _materialExtractedRepository.getExtractedMaterials(
        page: 1,
        brand: filter.brand,
        finish: filter.finish?.name,
        quality: filter.quality != null ? [filter.quality!.name] : null,
        search: filter.searchTerm,
      );
      result.when(
        ok: (response) {
          _rawExtractedMaterials = response.data.materials;
          _materials = _convertToMaterialModels(response.data.materials);
          _updateAvailableBrands();
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao filtrar materiais: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao filtrar materiais: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Carrega estatísticas dos materiais
  Future<void> loadStats() async {
    try {
      final result = await _materialRepository.getMaterialStats();
      result.when(
        ok: (stats) {
          _stats = stats;
          notifyListeners();
        },
        error: (error) {
          _setError('Erro ao carregar estatísticas: ${error.toString()}');
        },
      );
    } catch (e) {
      _setError('Erro inesperado ao carregar estatísticas: $e');
    }
  }

  /// Busca materiais por termo
  Future<void> searchMaterials(String searchTerm) async {
    final filter = _currentFilter.copyWith(searchTerm: searchTerm);
    await applyFilter(filter);
  }

  /// Filtrar por marca
  Future<void> filterByBrand(String? brand) async {
    final filter = _currentFilter.copyWith(brand: brand);
    await applyFilter(filter);
  }

  /// Filtrar por tipo
  Future<void> filterByType(MaterialType? type) async {
    final filter = _currentFilter.copyWith(type: type);
    await applyFilter(filter);
  }

  /// Filtrar por qualidade
  Future<void> filterByQuality(MaterialQuality? quality) async {
    final filter = _currentFilter.copyWith(quality: quality);
    await applyFilter(filter);
  }

  /// Filtrar por acabamento
  Future<void> filterByFinish(MaterialFinish? finish) async {
    final filter = _currentFilter.copyWith(finish: finish);
    await applyFilter(filter);
  }

  /// Limpa todos os filtros
  Future<void> clearFilters() async {
    _currentFilter = MaterialFilter();
    await loadMaterials();
  }

  /// Seleciona um material
  void selectMaterial(MaterialModel material) {
    if (!_selectedMaterials.contains(material)) {
      _selectedMaterials.add(material);
      notifyListeners();
    }
  }

  /// Remove a seleção de um material
  void unselectMaterial(MaterialModel material) {
    _selectedMaterials.remove(material);
    notifyListeners();
  }

  /// Verifica se um material está selecionado
  bool isMaterialSelected(MaterialModel material) {
    return _selectedMaterials.contains(material);
  }

  /// Limpa todas as seleções
  void clearSelection() {
    _selectedMaterials.clear();
    notifyListeners();
  }

  /// Seleciona todos os materiais visíveis
  void selectAllVisible() {
    for (final material in _materials) {
      if (!_selectedMaterials.contains(material)) {
        _selectedMaterials.add(material);
      }
    }
    notifyListeners();
  }

  /// Obtém o total do carrinho
  double get totalPrice {
    return _selectedMaterials.fold(
      0.0,
      (sum, material) => sum + material.price,
    );
  }

  /// Recarrega dados
  Future<void> refresh() async {
    _clearError();
    if (_currentFilter.hasFilters) {
      await applyFilter(_currentFilter);
    } else {
      await loadMaterials();
    }
  }

  /// Inicializa o ViewModel
  Future<void> initialize() async {
    // Primeiro tenta carregar materiais da API
    await loadMaterials();

    // Se não conseguiu carregar materiais da API, carrega estatísticas do repository antigo
    if (_materials.isEmpty) {
      try {
        await loadStats();
      } catch (e) {
        print('Erro ao carregar stats: $e');
      }
    }
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Converte MaterialExtracted para MaterialModel
  List<MaterialModel> _convertToMaterialModels(
    List<dynamic> extractedMaterials,
  ) {
    return extractedMaterials.map((extracted) {
      try {
        // Se for um Map, tenta converter diretamente
        if (extracted is Map<String, dynamic>) {
          // Cria um mapa compatível com MaterialModel
          return MaterialModel(
            id: extracted['id']?.toString() ?? '',
            name: extracted['name'] ?? 'Material sem nome',
            code: extracted['code'] ?? '',
            price:
                (extracted['unit_price'] ?? extracted['price'])?.toDouble() ??
                0.0,
            priceUnit: extracted['unit'] ?? 'Gal',
            type: MaterialType.interior, // Default
            quality: MaterialQuality.standard, // Default
            description: extracted['description'] ?? '',
            imageUrl: null,
            isAvailable: true,
          );
        } else {
          // Se for um objeto MaterialExtracted
          return MaterialModel(
            id: extracted.id?.toString() ?? '',
            name: extracted.name ?? 'Material sem nome',
            code: extracted.code ?? '',
            price: extracted.unitPrice ?? 0.0,
            priceUnit: extracted.unit ?? 'Gal',
            type: MaterialType.interior, // Default
            quality: MaterialQuality.standard, // Default
            description: extracted.description ?? '',
            imageUrl: null,
            isAvailable: true,
          );
        }
      } catch (e) {
        // Em caso de erro, cria um material padrão
        print('Erro ao converter material: $e');
        return MaterialModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Material - Erro de Conversão',
          code: 'ERROR',
          price: 0.0,
          priceUnit: 'Gal',
          type: MaterialType.interior,
          quality: MaterialQuality.standard,
          description: 'Erro na conversão dos dados',
          imageUrl: null,
          isAvailable: false,
        );
      }
    }).toList();
  }

  /// Atualiza a lista de marcas disponíveis baseada nos materiais carregados
  void _updateAvailableBrands() {
    _availableBrands.clear();
    final brands = _rawExtractedMaterials
        .map((material) => material.brand)
        .where((brand) => brand != null && brand.isNotEmpty)
        .cast<String>()
        .toSet()
        .toList();

    _availableBrands.addAll(brands);
    _availableBrands.sort();
  }

  // Lista temporária para acessar os dados extraídos
  List<dynamic> get extractedMaterials => _materials;

  /// Carrega dados de fallback quando a API falha
  void _loadFallbackMaterials() {
    try {
      // Dados de fallback baseados na estrutura da API real
      _materials = [
        MaterialModel(
          id: '1',
          name: 'Sherwin-Williams ProClassic Interior Latex',
          code: 'SW-PC-001',
          price: 52.99,
          priceUnit: 'Gal',
          type: MaterialType.interior,
          quality: MaterialQuality.high,
          description:
              'Tinta látex interior de alta qualidade com acabamento acetinado',
          imageUrl: null,
          isAvailable: true,
        ),
        MaterialModel(
          id: '2',
          name: 'Sherwin-Williams Duration Home Interior',
          code: 'SW-DH-002',
          price: 67.99,
          priceUnit: 'Gal',
          type: MaterialType.interior,
          quality: MaterialQuality.premium,
          description: 'Tinta premium com tecnologia de resistência à sujeira',
          imageUrl: null,
          isAvailable: true,
        ),
        MaterialModel(
          id: '3',
          name: 'Benjamin Moore Advance Interior Paint',
          code: 'BM-ADV-003',
          price: 64.99,
          priceUnit: 'Gal',
          type: MaterialType.interior,
          quality: MaterialQuality.premium,
          description:
              'Tinta acrílica alkyd com acabamento de qualidade profissional',
          imageUrl: null,
          isAvailable: true,
        ),
        MaterialModel(
          id: '4',
          name: 'Primer Sherwin-Williams ProBlock',
          code: 'SW-PB-004',
          price: 45.99,
          priceUnit: 'Gal',
          type: MaterialType.both,
          quality: MaterialQuality.standard,
          description:
              'Primer bloqueador de manchas para uso interno e externo',
          imageUrl: null,
          isAvailable: true,
        ),
        MaterialModel(
          id: '5',
          name: 'Benjamin Moore Regal Select',
          code: 'BM-RS-005',
          price: 58.99,
          priceUnit: 'Gal',
          type: MaterialType.interior,
          quality: MaterialQuality.high,
          description: 'Tinta de cobertura superior com tecnologia Gennex',
          imageUrl: null,
          isAvailable: true,
        ),
      ];

      _availableBrands.clear();
      _availableBrands.addAll([
        'Sherwin-Williams',
        'Benjamin Moore',
        'Behr',
        'PPG Paints',
        'Glidden',
        'Valspar',
      ]);

      print(
        '[MaterialListViewModel] Loaded ${_materials.length} fallback materials',
      );
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar dados de fallback: $e');
    }
  }
}
