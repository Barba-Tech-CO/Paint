import 'package:flutter/material.dart';

import '../utils/logger/app_logger.dart';
import '../domain/repository/paint_catalog_repository.dart';
import '../utils/result/result.dart';

/// ViewModel para a tela de seleção de cores
/// Implementa o padrão MVVM com logging integrado
class SelectColorsViewModel extends ChangeNotifier {
  final IPaintCatalogRepository _paintCatalogRepository;
  final AppLogger _logger;

  // Temporary fallback data while integrating with repository
  final List<String> _fallbackBrands = [
    'Sherwin-Williams',
    'Benjamin Moore',
    'Behr',
    'PP',
  ];

  final List<Map<String, dynamic>> _fallbackColors = [
    {
      'name': 'White',
      'code': 'SW6232',
      'price': '\$52.99/Gal',
      'color': Colors.grey[200],
    },
    {
      'name': 'Gray',
      'code': 'SW6233',
      'price': '\$51.99/Gal',
      'color': Colors.grey[500],
    },
    {
      'name': 'White Pink',
      'code': 'SW6235',
      'price': '\$46.99/Gal',
      'color': Colors.pink[100],
    },
    {
      'name': 'Pink',
      'code': 'SW6238',
      'price': '\$48.99/Gal',
      'color': Colors.pink[300],
    },
    {
      'name': 'Green',
      'code': 'SW6232',
      'price': '\$32.99/Gal',
      'color': Colors.lightGreen[300],
    },
    {
      'name': 'Aqua',
      'code': 'SW6232',
      'price': '\$52.99/Gal',
      'color': Colors.cyan[200],
    },
  ];

  List<String> _brands = [];
  List<Map<String, dynamic>> _colors = [];
  Map<String, dynamic>? _selectedColor;
  String? _selectedBrand;

  SelectColorsViewModel(this._paintCatalogRepository, this._logger) {
    _initializeData();
  }

  // Helper methods for common operations
  Future<void> _handleRepositoryCall<T>(
    Future<Result<T>> Function() repositoryCall,
    String operation,
    void Function(T data) onSuccess,
  ) async {
    setLoading(true);
    clearError();

    try {
      final result = await repositoryCall();
      result.when(
        ok: (data) {
          onSuccess(data);
          notifyListeners();
        },
        error: (error) {
          _setError('Error loading $operation: $error');
          _logger.error('Error loading $operation', error);
        },
      );
    } catch (e) {
      _setError('Unexpected error loading $operation');
      _logger.error('Unexpected error loading $operation', e);
    } finally {
      setLoading(false);
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  Map<String, dynamic> _convertColorToMap(dynamic color) {
    return {
      'name': color.name,
      'code': color.key,
      'price': '\$${color.price?.toStringAsFixed(2) ?? "N/A"}/Gal',
      'color': Colors.grey[200],
    };
  }

  /// Inicializa os dados carregando marcas
  Future<void> _initializeData() async {
    await loadBrands();
  }

  /// Carrega as marcas disponíveis
  Future<void> loadBrands() async {
    _logger.info('Loading brands...');

    await _handleRepositoryCall(
      () => _paintCatalogRepository.getBrands(),
      'brands',
      (brands) {
        _brands = brands;
        _logger.info('Brands loaded: ${_brands.length}');
      },
    );
  }

  /// Lista de marcas disponíveis
  List<String> get brands => _brands.isNotEmpty ? _brands : _fallbackBrands;

  /// Lista de cores disponíveis
  List<Map<String, dynamic>> get colors =>
      _colors.isNotEmpty ? _colors : _fallbackColors;

  /// Cor selecionada atualmente
  Map<String, dynamic>? get selectedColor => _selectedColor;

  /// Marca selecionada atualmente
  String? get selectedBrand => _selectedBrand;

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

    await _handleRepositoryCall(
      () => _paintCatalogRepository.getBrandColors(brand),
      'colors',
      (colors) {
        _colors = colors.map(_convertColorToMap).toList();
        _logger.info(
          'Colors Loaded - Brand: $brand - Color Count: ${_colors.length}',
        );
      },
    );
  }

  /// Gera o orçamento com as cores selecionadas
  Future<void> generateEstimate() async {
    if (!canGenerateEstimate) {
      _setError('Please select a color before generating estimate');
      _logger.warning('Attempt to generate estimate without selected color');
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
      _setError('Error generating estimate');
      _logger.error('Error generating estimate', error);
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

  /// Limpa a mensagem de erro
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
