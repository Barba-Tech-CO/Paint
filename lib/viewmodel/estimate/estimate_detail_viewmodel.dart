import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/estimate_model.dart';
import '../../domain/repository/estimate_repository.dart';

class EstimateDetailViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  EstimateModel? _selectedEstimate;
  bool _isLoading = false;
  String? _error;

  EstimateDetailViewModel(this._estimateRepository);

  // Getters
  EstimateModel? get selectedEstimate => _selectedEstimate;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Obtém detalhes de um orçamento
  Future<void> getEstimateDetails(String estimateId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.getEstimate(estimateId);
      if (result is Ok) {
        _selectedEstimate = result.asOk.value.data;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Erro ao obter detalhes do orçamento: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Cria um novo orçamento
  Future<EstimateModel?> createEstimate({
    required String projectName,
    required String clientName,
    required ProjectType projectType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.createEstimate(
        projectName: projectName,
        clientName: clientName,
        projectType: projectType,
      );

      if (result is Ok && result.asOk.value.data != null) {
        _selectedEstimate = result.asOk.value.data;
        notifyListeners();
        return result.asOk.value.data;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return null;
    } catch (e) {
      _setError('Erro ao criar orçamento: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um orçamento
  Future<bool> updateEstimate(
    String estimateId, {
    String? projectName,
    String? clientName,
    ProjectType? projectType,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.updateEstimate(
        estimateId,
        projectName: projectName,
        clientName: clientName,
        projectType: projectType,
      );

      if (result is Ok && result.asOk.value.data != null) {
        _selectedEstimate = result.asOk.value.data;
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Erro ao atualizar orçamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove um orçamento
  Future<bool> deleteEstimate(String estimateId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.deleteEstimate(estimateId);

      if (result is Ok && result.asOk.value) {
        if (_selectedEstimate?.id == estimateId) {
          _selectedEstimate = null;
        }
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Erro ao remover orçamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza o status de um orçamento
  Future<bool> updateEstimateStatus(
    String estimateId,
    EstimateStatus status,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.updateEstimateStatus(
        estimateId,
        status,
      );

      if (result is Ok && result.asOk.value.data != null) {
        _selectedEstimate = result.asOk.value.data;
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Erro ao atualizar status do orçamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Finaliza o orçamento
  Future<bool> completeEstimate(String estimateId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.completeEstimate(estimateId);

      if (result is Ok && result.asOk.value.data != null) {
        _selectedEstimate = result.asOk.value.data;
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Erro ao finalizar orçamento: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Envia o orçamento para o GHL
  Future<bool> sendToGHL(String estimateId) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _estimateRepository.sendToGHL(estimateId);

      if (result is Ok && result.asOk.value) {
        // Atualiza o status para enviado
        await updateEstimateStatus(estimateId, EstimateStatus.sent);
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Erro ao enviar orçamento para GHL: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona um orçamento
  void selectEstimate(EstimateModel estimate) {
    _selectedEstimate = estimate;
    notifyListeners();
  }

  /// Limpa a seleção de orçamento
  void clearSelection() {
    _selectedEstimate = null;
    notifyListeners();
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
