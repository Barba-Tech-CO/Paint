import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/estimate_model.dart';
import '../../domain/repository/estimate_repository.dart';

class EstimateCalculationViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  EstimateModel? _currentEstimate;
  bool _isCalculating = false;
  String? _error;
  double _totalCost = 0.0;
  double _totalArea = 0.0;

  EstimateCalculationViewModel(this._estimateRepository);

  // Getters
  EstimateModel? get currentEstimate => _currentEstimate;
  bool get isCalculating => _isCalculating;
  String? get error => _error;
  double get totalCost => _totalCost;
  double get totalArea => _totalArea;

  /// Seleciona elementos e calcula custos
  Future<bool> selectElementsAndCalculate(
    String estimateId,
    List<String> elementIds,
  ) async {
    _setCalculating(true);
    _clearError();

    try {
      final result = await _estimateRepository.selectElements(
        estimateId,
        elementIds,
      );

      if (result is Ok) {
        final data = result.asOk.value;
        // Extract relevant data from the Map<String, dynamic>
        _totalCost = (data['totalCost'] as num?)?.toDouble() ?? 0.0;
        _totalArea = (data['totalArea'] as num?)?.toDouble() ?? 0.0;
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Error calculating estimate: $e');
      return false;
    } finally {
      _setCalculating(false);
    }
  }

  /// Atualiza os cálculos baseado no orçamento atual
  void _updateCalculations() {
    if (_currentEstimate == null) return;

    _totalCost = _currentEstimate!.totalCost ?? 0.0;
    _totalArea = _currentEstimate!.totalArea ?? 0.0;
  }

  /// Define o orçamento atual
  void setCurrentEstimate(EstimateModel estimate) {
    _currentEstimate = estimate;
    _updateCalculations();
    notifyListeners();
  }

  /// Limpa o orçamento atual
  void clearCurrentEstimate() {
    _currentEstimate = null;
    _totalCost = 0.0;
    _totalArea = 0.0;
    notifyListeners();
  }

  /// Obtém o custo por metro quadrado
  double get costPerSquareMeter {
    if (_totalArea > 0) {
      return _totalCost / _totalArea;
    }
    return 0.0;
  }

  /// Obtém o custo formatado
  String get formattedTotalCost {
    return 'R\$ ${_totalCost.toStringAsFixed(2)}';
  }

  /// Obtém a área formatada
  String get formattedTotalArea {
    return '${_totalArea.toStringAsFixed(2)} m²';
  }

  /// Obtém o custo por m² formatado
  String get formattedCostPerSquareMeter {
    return 'R\$ ${costPerSquareMeter.toStringAsFixed(2)}/m²';
  }

  // Métodos privados para gerenciar estado
  void _setCalculating(bool calculating) {
    _isCalculating = calculating;
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
