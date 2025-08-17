import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/paint_catalog_model.dart';
import '../../domain/repository/paint_catalog_repository.dart';

class PaintCatalogDetailViewModel extends ChangeNotifier {
  final IPaintCatalogRepository _paintCatalogRepository;

  PaintBrand? _selectedBrand;
  PaintColor? _selectedColor;
  ColorDetail? _selectedColorDetail;
  PaintCalculation? _currentCalculation;
  bool _isLoading = false;
  String? _error;

  PaintCatalogDetailViewModel(this._paintCatalogRepository);

  // Getters
  PaintBrand? get selectedBrand => _selectedBrand;
  PaintColor? get selectedColor => _selectedColor;
  ColorDetail? get selectedColorDetail => _selectedColorDetail;
  PaintCalculation? get currentCalculation => _currentCalculation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtém detalhes de uma cor
  Future<void> getColorDetail(
    String brandKey,
    String colorKey,
    String usage,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getColorDetail(
        brandKey,
        colorKey,
        usage,
      );
      if (result is Ok) {
        _selectedColorDetail = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao obter detalhes da cor: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calcula necessidade de tinta
  Future<bool> calculatePaintNeeds({
    required String brandKey,
    required String colorKey,
    required String usage,
    required double area,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.calculatePaintNeeds(
        brandKey: brandKey,
        colorKey: colorKey,
        usage: usage,
        area: area,
      );
      if (result is Ok) {
        _currentCalculation = result.asOk.value;
        notifyListeners();
        return true;
      } else {
        _setError(result.asError.error.toString());
        return false;
      }
    } catch (e) {
      _setError('Erro ao calcular necessidade de tinta: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona uma marca
  void selectBrand(PaintBrand brand) {
    _selectedBrand = brand;
    _selectedColor = null;
    _selectedColorDetail = null;
    _currentCalculation = null;
    notifyListeners();
  }

  /// Seleciona uma cor
  void selectColor(PaintColor color) {
    _selectedColor = color;
    _selectedColorDetail = null;
    _currentCalculation = null;
    notifyListeners();
  }

  /// Limpa a seleção de marca
  void clearBrandSelection() {
    _selectedBrand = null;
    _selectedColor = null;
    _selectedColorDetail = null;
    _currentCalculation = null;
    notifyListeners();
  }

  /// Limpa a seleção de cor
  void clearColorSelection() {
    _selectedColor = null;
    _selectedColorDetail = null;
    _currentCalculation = null;
    notifyListeners();
  }

  /// Limpa o cálculo atual
  void clearCalculation() {
    _currentCalculation = null;
    notifyListeners();
  }

  /// Limpa todos os dados
  void clearAll() {
    _selectedBrand = null;
    _selectedColor = null;
    _selectedColorDetail = null;
    _currentCalculation = null;
    _clearError();
    notifyListeners();
  }

  /// Obtém o custo total formatado
  String get formattedTotalCost {
    if (_currentCalculation == null) return 'R\$ 0,00';
    return 'R\$ ${_currentCalculation!.totalCost.toStringAsFixed(2)}';
  }

  /// Obtém a quantidade total formatada
  String get formattedTotalQuantity {
    if (_currentCalculation == null) return '0 galões';
    return '${_currentCalculation!.gallonsNeeded} galões';
  }

  /// Obtém o custo por galão formatado
  String get formattedCostPerGallon {
    if (_currentCalculation == null ||
        _currentCalculation!.gallonsNeeded == 0) {
      return 'R\$ 0,00/galão';
    }
    final costPerGallon =
        _currentCalculation!.totalCost / _currentCalculation!.gallonsNeeded;
    return 'R\$ ${costPerGallon.toStringAsFixed(2)}/galão';
  }

  /// Obtém a área formatada
  String get formattedArea {
    if (_currentCalculation == null) return '0 m²';
    return '${_currentCalculation!.area.toStringAsFixed(2)} m²';
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
}
