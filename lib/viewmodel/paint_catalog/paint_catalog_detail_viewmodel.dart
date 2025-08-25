import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/paint_catalog_model.dart';
import '../../domain/repository/paint_catalog_repository.dart';

class PaintCatalogDetailViewModel extends ChangeNotifier {
  final IPaintCatalogRepository _paintCatalogRepository;

  String? _selectedBrand;
  PaintColor? _selectedColor;
  PaintColor? _selectedColorDetail;
  Map<String, dynamic>? _currentCalculation;
  bool _isLoading = false;
  String? _error;

  PaintCatalogDetailViewModel(this._paintCatalogRepository);

  // Getters
  String? get selectedBrand => _selectedBrand;
  PaintColor? get selectedColor => _selectedColor;
  PaintColor? get selectedColorDetail => _selectedColorDetail;
  Map<String, dynamic>? get currentCalculation => _currentCalculation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtém detalhes de uma cor
  Future<void> getColorDetail(String colorId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.getColorDetails(colorId);
      if (result is Ok) {
        _selectedColorDetail = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error getting color details: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Calcula necessidade de tinta
  Future<bool> calculatePaintNeeds({
    required String colorId,
    required double areaInSquareMeters,
    required int coats,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _paintCatalogRepository.calculatePaintNeeds(
        areaInSquareMeters: areaInSquareMeters,
        colorId: colorId,
        coats: coats,
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
      _setError('Error calculating paint needs: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona uma marca
  void selectBrand(String brand) {
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
    final totalCost = _currentCalculation!['totalCost'] ?? 0.0;
    return 'R\$ ${totalCost.toStringAsFixed(2)}';
  }

  /// Obtém a quantidade total formatada
  String get formattedTotalQuantity {
    if (_currentCalculation == null) return '0 galões';
    final gallonsNeeded = _currentCalculation!['gallonsNeeded'] ?? 0;
    return '$gallonsNeeded galões';
  }

  /// Obtém o custo por galão formatado
  String get formattedCostPerGallon {
    if (_currentCalculation == null) return 'R\$ 0,00/galão';
    final totalCost = _currentCalculation!['totalCost'] ?? 0.0;
    final gallonsNeeded = _currentCalculation!['gallonsNeeded'] ?? 0;
    if (gallonsNeeded == 0) return 'R\$ 0,00/galão';
    final costPerGallon = totalCost / gallonsNeeded;
    return 'R\$ ${costPerGallon.toStringAsFixed(2)}/galão';
  }

  /// Obtém a área formatada
  String get formattedArea {
    if (_currentCalculation == null) return '0 m²';
    final area = _currentCalculation!['area'] ?? 0.0;
    return '${area.toStringAsFixed(2)} m²';
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
