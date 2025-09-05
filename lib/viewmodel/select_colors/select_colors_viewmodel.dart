import 'package:flutter/material.dart';

import '../../utils/logger/app_logger.dart';
import '../../domain/repository/material_extracted_repository.dart';

/// ViewModel para a tela de seleção de cores
/// Implementa o padrão MVVM com logging integrado
class SelectColorsViewModel extends ChangeNotifier {
  final IMaterialExtractedRepository _materialExtractedRepository;
  final AppLogger _logger;

  // Mapeamento de marcas para normalização
  static const Map<String, String> _brandMapping = {
    // Variações possíveis -> Formato esperado pela API
    'sherwin': 'Sherwin-Williams',
    'sherwin williams': 'Sherwin-Williams',
    'sherwin-williams': 'Sherwin-Williams',
    'sherwinwilliams': 'Sherwin-Williams',
    'sw': 'Sherwin-Williams',

    'benjamin': 'Benjamin Moore',
    'benjamin moore': 'Benjamin Moore',
    'benjaminmoore': 'Benjamin Moore',
    'bm': 'Benjamin Moore',

    'behr': 'Behr',

    'ppg': 'PPG',
    'p.p.g': 'PPG',
    'p p g': 'PPG',

    'dulux': 'Dulux',
    'suvinil': 'Suvinil',
    'coral': 'Coral',
    'eucatex': 'Eucatex',
    'ypiranga': 'Ypiranga',
  };

  List<String> _brands = [];
  List<Map<String, dynamic>> _colors = [];
  Map<String, dynamic>? _selectedColor;
  String? _selectedBrand;

  SelectColorsViewModel(this._materialExtractedRepository, this._logger) {
    _initializeData();
  }

  /// Inicializa os dados carregando marcas
  Future<void> _initializeData() async {
    await loadBrands();
  }

  /// Normaliza o nome da marca inserido pelo usuário para o formato da API
  String? _normalizeBrandName(String userInput) {
    // Remove espaços extras e converte para lowercase
    String normalized = userInput.trim().toLowerCase();

    // Remove caracteres especiais comuns (exceto hífen)
    normalized = normalized.replaceAll(RegExp(r'[^\w\s\-]'), '');

    // Remove espaços duplos
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Primeiro tenta busca exata no mapeamento
    if (_brandMapping.containsKey(normalized)) {
      return _brandMapping[normalized];
    }

    // Busca por aproximação (fuzzy search)
    return _findSimilarBrand(normalized);
  }

  /// Encontra a marca mais similar usando diferentes estratégias
  String? _findSimilarBrand(String input) {
    // Estratégia 1: Busca por palavras-chave
    for (String key in _brandMapping.keys) {
      if (input.contains(key) || key.contains(input)) {
        return _brandMapping[key];
      }
    }

    // Estratégia 2: Busca por iniciais
    if (input.length <= 3) {
      // Provável sigla
      for (String key in _brandMapping.keys) {
        if (key == input ||
            key.replaceAll(' ', '').toLowerCase().startsWith(input)) {
          return _brandMapping[key];
        }
      }
    }

    // Estratégia 3: Busca por primeira palavra
    String firstWord = input.split(' ').first;
    for (String key in _brandMapping.keys) {
      if (key.split(' ').first == firstWord) {
        return _brandMapping[key];
      }
    }

    // Se não encontrou nada, retorna null
    return null;
  }

  /// Busca marcas disponíveis (sugestões para autocomplete)
  List<String> getSuggestedBrands(String input) {
    if (input.isEmpty) return _brands;

    String normalized = input.trim().toLowerCase();
    List<String> suggestions = [];

    // Adiciona marcas que começam com o input
    suggestions.addAll(
      _brands.where((brand) => brand.toLowerCase().startsWith(normalized)),
    );

    // Adiciona marcas que contêm o input
    suggestions.addAll(
      _brands.where(
        (brand) =>
            brand.toLowerCase().contains(normalized) &&
            !brand.toLowerCase().startsWith(normalized),
      ),
    );

    return suggestions.take(5).toList(); // Limite de 5 sugestões
  }

  /// Carrega as marcas disponíveis
  Future<void> loadBrands() async {
    _logger.info('Loading brands...');
    setLoading(true);
    clearError();

    try {
      final result = await _materialExtractedRepository.getAvailableBrands();
      result.when(
        ok: (brands) {
          _brands = brands; // Brands are now strings directly
          notifyListeners();
          _logger.info('Brands loaded: ${_brands.length}');
        },
        error: (error) {
          setError('Erro ao carregar marcas: $error');
          _logger.error('Erro ao carregar marcas', error);
          _brands = []; // No brands available from API
        },
      );
    } catch (e) {
      setError('Erro inesperado ao carregar marcas: $e');
      _logger.error('Erro inesperado ao carregar marcas', e);
      _brands = [];
    } finally {
      setLoading(false);
    }
  }

  /// Lista de marcas disponíveis
  List<String> get brands => _brands;

  /// Lista de cores disponíveis
  List<Map<String, dynamic>> get colors => _colors;

  /// Cor selecionada atualmente
  Map<String, dynamic>? get selectedColor => _selectedColor;

  /// Marca selecionada atualmente
  String? get selectedBrand => _selectedBrand;

  /// Busca marcas que correspondem ao termo de busca
  List<String> searchBrands(String searchTerm) {
    if (searchTerm.isEmpty) return _brands;

    final normalizedSearch = searchTerm.toLowerCase().trim();

    return _brands.where((brand) {
      final normalizedBrand = brand.toLowerCase();
      // Busca por correspondência no início, no meio ou mapeamento
      return normalizedBrand.contains(normalizedSearch) ||
          _brandMapping.keys.any(
            (key) =>
                key.contains(normalizedSearch) && _brandMapping[key] == brand,
          );
    }).toList();
  }

  /// Obtém sugestões de marcas baseadas no input do usuário
  List<String> getBrandSuggestions(String input) {
    if (input.isEmpty) return _brands.take(5).toList();

    final suggestions = searchBrands(input);

    // Se encontrou sugestões diretas, retorna elas
    if (suggestions.isNotEmpty) {
      return suggestions.take(5).toList();
    }

    // Caso contrário, busca por similaridade
    return _brands
        .where((brand) {
          final normalizedBrand = brand.toLowerCase();
          final normalizedInput = input.toLowerCase();

          // Verifica se alguma palavra do input está na marca
          final inputWords = normalizedInput.split(' ');
          return inputWords.any(
            (word) => word.isNotEmpty && normalizedBrand.contains(word),
          );
        })
        .take(5)
        .toList();
  }

  /// Seleciona uma cor
  void selectColor(Map<String, dynamic> colorData, String brand) {
    _selectedColor = colorData;
    _selectedBrand = brand;

    _logger.info(
      'Color Selected: ${colorData['name']} - Brand: $brand - Price: ${colorData['price']}',
    );

    notifyListeners();
  }

  /// Carrega as cores para uma marca específica
  Future<void> loadColorsForBrand(String brand) async {
    _logger.info('Loading colors for brand: $brand');
    setLoading(true);
    clearError();

    try {
      // Normaliza o nome da marca para o formato da API
      String? normalizedBrand = _normalizeBrandName(brand);
      if (normalizedBrand == null) {
        setError(
          'Marca "$brand" não encontrada. Tente: ${_brandMapping.values.take(3).join(", ")}',
        );
        _logger.warning('Brand not found: $brand');
        _colors = [];
        setLoading(false);
        return;
      }

      _logger.info('Normalized brand: $brand -> $normalizedBrand');

      final result = await _materialExtractedRepository
          .getExtractedMaterialsByBrand(normalizedBrand);
      result.when(
        ok: (response) {
          // Convert MaterialExtracted to Map for compatibility
          _colors = response.data.materials
              .map(
                (material) => {
                  'name': material.name,
                  'code': material.code ?? 'N/A',
                  'price': material.unitPrice != null
                      ? '\$${material.unitPrice!.toStringAsFixed(2)}/${material.unit ?? "Gal"}'
                      : 'N/A',
                  'color': Colors.grey[200], // Default color representation
                  'category': material.category,
                  'description': material.description,
                  'quantity': material.quantity,
                },
              )
              .toList();
          notifyListeners();
          _logger.info(
            'Colors Loaded - Brand: $brand - Color Count: ${_colors.length}',
          );
        },
        error: (error) {
          setError('Erro ao carregar cores: $error');
          _logger.error('Erro ao carregar cores para $brand', error);
          // No colors available from API
          _colors = [];
        },
      );
    } catch (e) {
      setError('Erro inesperado ao carregar cores: $e');
      _logger.error('Erro inesperado ao carregar cores para $brand', e);
      _colors = [];
    } finally {
      setLoading(false);
    }
  }

  /// Carrega materiais com filtros específicos
  Future<void> loadMaterialsWithFilters({
    String? brand,
    String? ambient,
    String? finish,
    List<String>? quality,
    String? search,
    int? page,
  }) async {
    _logger.info('Loading materials with filters...');
    setLoading(true);
    clearError();

    try {
      final result = await _materialExtractedRepository.getExtractedMaterials(
        brand: brand,
        ambient: ambient,
        finish: finish,
        quality: quality,
        search: search,
        page: page,
        sortBy: 'created_at',
        sortOrder: 'desc',
      );

      result.when(
        ok: (response) {
          // Convert MaterialExtracted to Map for compatibility
          _colors = response.data.materials
              .map(
                (material) => {
                  'name': material.name,
                  'code': material.code ?? 'N/A',
                  'price': material.unitPrice != null
                      ? '\$${material.unitPrice!.toStringAsFixed(2)}/${material.unit ?? "Gal"}'
                      : 'N/A',
                  'color': Colors.grey[200], // Default color representation
                  'category': material.category,
                  'description': material.description,
                  'quantity': material.quantity,
                  'brand': material.brand,
                },
              )
              .toList();
          notifyListeners();
          _logger.info('Materials loaded with filters: ${_colors.length}');
        },
        error: (error) {
          setError('Erro ao carregar materiais: $error');
          _logger.error('Erro ao carregar materiais com filtros', error);
          _colors = [];
        },
      );
    } catch (e) {
      setError('Erro inesperado ao carregar materiais: $e');
      _logger.error('Erro inesperado ao carregar materiais com filtros', e);
      _colors = [];
    } finally {
      setLoading(false);
    }
  }

  /// Busca materiais por termo de busca normalizado
  Future<void> searchMaterialsByBrand(String userInput) async {
    String? normalizedBrand = _normalizeBrandName(userInput);
    if (normalizedBrand != null) {
      await loadColorsForBrand(normalizedBrand);
    } else {
      setError('Marca "$userInput" não encontrada');
      _colors = [];
      notifyListeners();
    }
  }

  /// Método público para validar e sugerir correções de marca
  String? validateAndNormalizeBrand(String userInput) {
    String? normalized = _normalizeBrandName(userInput);
    if (normalized != null) {
      _logger.info('Brand validated: $userInput -> $normalized');
    }
    return normalized;
  }

  /// Obtém todas as marcas válidas (para dropdown/autocomplete)
  List<String> get validBrands => _brandMapping.values.toSet().toList();

  /// Busca materiais por termo
  Future<void> searchMaterials(String searchTerm) async {
    await loadMaterialsWithFilters(search: searchTerm);
  }

  /// Filtra materiais por ambiente
  Future<void> filterByAmbient(String ambient) async {
    await loadMaterialsWithFilters(ambient: ambient);
  }

  /// Filtra materiais por acabamento
  Future<void> filterByFinish(String finish) async {
    await loadMaterialsWithFilters(finish: finish);
  }

  /// Filtra materiais por qualidade
  Future<void> filterByQuality(List<String> quality) async {
    await loadMaterialsWithFilters(quality: quality);
  }

  /// Carrega todas as categorias disponíveis
  Future<void> loadCategories() async {
    _logger.info('Loading categories...');
    try {
      final result = await _materialExtractedRepository
          .getAvailableCategories();
      result.when(
        ok: (categories) {
          // Store categories if needed in the future
          _logger.info('Categories loaded: ${categories.length}');
        },
        error: (error) {
          _logger.error('Erro ao carregar categorias', error);
        },
      );
    } catch (e) {
      _logger.error('Erro inesperado ao carregar categorias', e);
    }
  }

  /// Gera o orçamento com as cores selecionadas
  Future<void> generateEstimate() async {
    if (_selectedColor == null || _selectedBrand == null) {
      setError('Por favor, selecione uma cor antes de gerar o orçamento');
      _logger.warning('Tentativa de gerar orçamento sem cor selecionada');
      return;
    }

    setLoading(true);
    clearError();

    try {
      _logger.info(
        'Generating estimate for color: ${_selectedColor!['name']}',
      );

      // Simula o processo de geração de orçamento
      await Future.delayed(const Duration(seconds: 1));

      _logger.info(
        'Estimate Generated - Color: ${_selectedColor!['name']} - Brand: $_selectedBrand - Price: ${_selectedColor!['price']}',
      );
    } catch (error) {
      setError('Erro ao gerar orçamento: $error');
      _logger.error('Erro ao gerar orçamento', error);
    } finally {
      setLoading(false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    _selectedColor = null;
    _selectedBrand = null;
    _logger.info('Seleção de cores limpa');
    notifyListeners();
  }

  /// Verifica se pode gerar orçamento
  bool get canGenerateEstimate =>
      _selectedColor != null && _selectedBrand != null;

  bool _isLoading = false;
  String? _errorMessage;

  /// Indica se está carregando
  bool get isLoading => _isLoading;

  /// Mensagem de erro atual
  String? get errorMessage => _errorMessage;

  /// Define o estado de carregamento
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Define uma mensagem de erro
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Exemplo de uso completo do endpoint com todos os parâmetros
  /// Este método demonstra como usar todos os filtros disponíveis na API
  /// Endpoint: "/api/materials/extracted?brand=Sherwin&ambient=interior&finish=flat&quality[]=A&search=paint&page=1&sort_by=created_at&sort_order=desc"
  Future<void> loadMaterialsWithAllFilters() async {
    await loadMaterialsWithFilters(
      brand: 'Sherwin', // Filtro por marca
      ambient: 'interior', // Filtro por ambiente (interior/exterior)
      finish: 'flat', // Filtro por acabamento
      quality: ['A'], // Filtro por qualidade (array)
      search: 'paint', // Busca por termo
      page: 1, // Paginação
    );
  }

  /// Exemplo de uso da normalização de marcas
  /// Demonstra como diferentes inputs do usuário são convertidos
  void demonstrateNormalization() {
    final examples = [
      'sherwin', // -> 'Sherwin-Williams'
      'sw', // -> 'Sherwin-Williams'
      'benjamin moore', // -> 'Benjamin Moore'
      'bm', // -> 'Benjamin Moore'
      'behr', // -> 'Behr'
      'ppg paints', // -> 'PPG'
    ];

    for (String example in examples) {
      String? normalized = validateAndNormalizeBrand(example);
      _logger.info('Input: "$example" -> Normalized: "$normalized"');
    }
  }
}
