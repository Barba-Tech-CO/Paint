import 'package:flutter/material.dart';

import '../../../../service/logger_service.dart';

/// ViewModel para a tela de seleção de cores
/// Implementa o padrão MVVM com logging integrado
class SelectColorsViewModel extends ChangeNotifier {
  final List<String> _brands = [
    'Sherwin-Williams',
    'Benjamin Moore',
    'Behr',
    'PP',
  ];

  final List<Map<String, dynamic>> _colors = [
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

  Map<String, dynamic>? _selectedColor;
  String? _selectedBrand;

  SelectColorsViewModel();

  /// Lista de marcas disponíveis
  List<String> get brands => _brands;

  /// Lista de cores disponíveis
  List<Map<String, dynamic>> get colors => _colors;

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

    // Simula um delay de carregamento
    await Future.delayed(const Duration(milliseconds: 500));

    LoggerService.info(
      'Colors Loaded - Brand: $brand - Color Count: ${_colors.length}',
    );
  }

  /// Gera o orçamento com as cores selecionadas
  Future<void> generateEstimate() async {
    if (_selectedColor == null || _selectedBrand == null) {
      setError('Por favor, selecione uma cor antes de gerar o orçamento');
      LoggerService.warning('Tentativa de gerar orçamento sem cor selecionada');
      return;
    }

    setLoading(true);
    clearError();

    try {
      LoggerService.info(
        'Gerando orçamento para cor: ${_selectedColor!['name']}',
      );

      // Simula o processo de geração de orçamento
      await Future.delayed(const Duration(seconds: 1));

      LoggerService.info(
        'Estimate Generated - Color: ${_selectedColor!['name']} - Brand: $_selectedBrand - Price: ${_selectedColor!['price']}',
      );
    } catch (error) {
      setError('Erro ao gerar orçamento: $error');
      LoggerService.error('Erro ao gerar orçamento', error);
    } finally {
      setLoading(false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    _selectedColor = null;
    _selectedBrand = null;
    LoggerService.info('Seleção de cores limpa');
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
