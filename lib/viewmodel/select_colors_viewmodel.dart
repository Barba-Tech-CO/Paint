import 'package:flutter/material.dart';

import '../service/logger_service.dart';
import '../domain/repository/paint_catalog_repository.dart';

/// ViewModel para a tela de seleção de cores
/// Implementa o padrão MVVM com logging integrado
class SelectColorsViewModel extends ChangeNotifier {
  final IPaintCatalogRepository _paintCatalogRepository;

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

  SelectColorsViewModel(this._paintCatalogRepository) {
    _initializeData();
  }

  /// Inicializa os dados carregando marcas
  Future<void> _initializeData() async {
    await loadBrands();
  }

  /// Carrega as marcas disponíveis
  Future<void> loadBrands() async {
    setLoading(true);
    clearError();

    try {
      final result = await _paintCatalogRepository.getBrands();
      result.when(
        ok: (brands) {
          _brands = brands; // Brands are now strings directly
          notifyListeners();
          LoggerService.info('Brands loaded: ${_brands.length}');
        },
        error: (error) {
          setError('Error loading brands: $error');
          LoggerService.error('Error loading brands', error);
          _brands = []; // Will fall back to fallback brands
        },
      );
    } catch (e) {
      setError('Unexpected error loading brands: $e');
      LoggerService.error('Unexpected error loading brands', e);
      _brands = [];
    } finally {
      setLoading(false);
    }
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

    LoggerService.info(
      'Color Selected: ${colorData['name']} - Brand: $brand - Price: ${colorData['price']}',
    );

    notifyListeners();
  }

  /// Carrega as cores para uma marca específica
  Future<void> loadColorsForBrand(String brand) async {
    LoggerService.info('Carregando cores para a marca: $brand');
    setLoading(true);
    clearError();

    try {
      final result = await _paintCatalogRepository.getBrandColors(brand);
      result.when(
        ok: (colors) {
          // Convert PaintColor to Map for compatibility
          _colors = colors
              .map(
                (color) => {
                  'name': color.name,
                  'code': color.key,
                  'price': '\$${color.price?.toStringAsFixed(2) ?? "N/A"}/Gal',
                  'color': Colors.grey[200], // Default color representation
                },
              )
              .toList();
          notifyListeners();
          LoggerService.info(
            'Colors Loaded - Brand: $brand - Color Count: ${_colors.length}',
          );
        },
        error: (error) {
          setError('Error loading colors: $error');
          LoggerService.error('Error loading colors for $brand', error);
          // Fall back to using fallback colors
          _colors = [];
        },
      );
    } catch (e) {
      setError('Unexpected error loading colors: $e');
      LoggerService.error('Unexpected error loading colors for $brand', e);
      _colors = [];
    } finally {
      setLoading(false);
    }
  }

  /// Gera o orçamento com as cores selecionadas
  Future<void> generateEstimate() async {
    if (_selectedColor == null || _selectedBrand == null) {
      setError('Please select a color before generating the estimate');
      LoggerService.warning(
        'Attempt to generate estimate without selected color',
      );
      return;
    }

    setLoading(true);
    clearError();

    try {
      LoggerService.info(
        'Generating estimate for color: ${_selectedColor!['name']}',
      );

      // Simula o processo de geração de orçamento
      await Future.delayed(const Duration(seconds: 1));

      LoggerService.info(
        'Estimate Generated - Color: ${_selectedColor!['name']} - Brand: $_selectedBrand - Price: ${_selectedColor!['price']}',
      );
    } catch (error) {
      setError('Error generating estimate: $error');
      LoggerService.error('Error generating estimate', error);
    } finally {
      setLoading(false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    _selectedColor = null;
    _selectedBrand = null;
    LoggerService.info('Color selection cleared');
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
}
