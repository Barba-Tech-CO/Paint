import 'package:flutter/material.dart';

/// ViewModel para a tela de seleção de cores
/// Implementa o padrão MVVM com logging integrado
class SelectColorsViewModel extends ChangeNotifier {
  final List<Map<String, dynamic>> _colors = [
    {
      'id': '1',
      'name': 'Branco',
      'hex': '#FFFFFF',
      'price': 45.90,
      'brand': 'Suvinil',
    },
    {
      'id': '2',
      'name': 'Preto',
      'hex': '#000000',
      'price': 52.80,
      'brand': 'Coral',
    },
    {
      'id': '3',
      'name': 'Azul',
      'hex': '#0000FF',
      'price': 48.50,
      'brand': 'Suvinil',
    },
    {
      'id': '4',
      'name': 'Vermelho',
      'hex': '#FF0000',
      'price': 55.20,
      'brand': 'Coral',
    },
    {
      'id': '5',
      'name': 'Verde',
      'hex': '#00FF00',
      'price': 49.90,
      'brand': 'Suvinil',
    },
    {
      'id': '6',
      'name': 'Amarelo',
      'hex': '#FFFF00',
      'price': 47.30,
      'brand': 'Coral',
    },
  ];

  final List<String> _brands = ['Suvinil', 'Coral', 'Sherwin Williams'];

  Map<String, dynamic>? _selectedColor;
  String? _selectedBrand;

  SelectColorsViewModel();

  /// Lista de cores disponíveis
  List<Map<String, dynamic>> get colors => _colors;

  /// Lista de marcas disponíveis
  List<String> get brands => _brands;

  /// Cor selecionada atualmente
  Map<String, dynamic>? get selectedColor => _selectedColor;

  /// Marca selecionada atualmente
  String? get selectedBrand => _selectedBrand;

  /// Seleciona uma cor
  void selectColor(Map<String, dynamic> colorData, String brand) {
    _selectedColor = colorData;
    _selectedBrand = brand;

    notifyListeners();
  }

  /// Carrega as cores para uma marca específica
  Future<void> loadColorsForBrand(String brand) async {
    // Simula um delay de carregamento
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Gera o orçamento com as cores selecionadas
  Future<void> generateEstimate() async {
    if (_selectedColor == null || _selectedBrand == null) {
      setError('Por favor, selecione uma cor antes de gerar o orçamento');
      return;
    }

    setLoading(true);
    clearError();

    try {
      // Simula o processo de geração de orçamento
      await Future.delayed(const Duration(seconds: 1));
    } catch (error) {
      setError('Erro ao gerar orçamento: $error');
    } finally {
      setLoading(false);
    }
  }

  /// Limpa a seleção atual
  void clearSelection() {
    _selectedColor = null;
    _selectedBrand = null;
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
