import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/estimate_model.dart';
import '../../domain/repository/estimate_repository.dart';
import '../../utils/command/command.dart';

enum EstimateListState { initial, loading, loaded, error }

class EstimateListViewModel extends ChangeNotifier {
  final IEstimateRepository _estimateRepository;

  EstimateListViewModel(this._estimateRepository);

  // State
  EstimateListState _state = EstimateListState.initial;
  EstimateListState get state => _state;

  // Data
  List<EstimateModel> _estimates = [];
  List<EstimateModel> get estimates => _estimates;

  // Pagination
  int _currentPage = 0;
  int get currentPage => _currentPage;
  int _totalEstimates = 0;
  int get totalEstimates => _totalEstimates;
  static const int _pageSize = 20;

  // Filters
  String? _statusFilter;
  String? get statusFilter => _statusFilter;

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Commands
  late final Command0<void> _loadEstimatesCommand;
  late final Command0<void> _loadMoreEstimatesCommand;
  late final Command1<void, String?> _filterByStatusCommand;
  late final Command1<void, String> _deleteEstimateCommand;

  Command0<void> get loadEstimatesCommand => _loadEstimatesCommand;
  Command0<void> get loadMoreEstimatesCommand => _loadMoreEstimatesCommand;
  Command1<void, String?> get filterByStatusCommand => _filterByStatusCommand;
  Command1<void, String> get deleteEstimateCommand => _deleteEstimateCommand;

  // Computed properties
  bool get isLoading =>
      _state == EstimateListState.loading || _loadEstimatesCommand.running;
  bool get hasError =>
      _state == EstimateListState.error || _errorMessage != null;
  bool get hasMoreEstimates => _estimates.length < _totalEstimates;

  void _initializeCommands() {
    _loadEstimatesCommand = Command0(() async {
      _setState(EstimateListState.loading);
      _clearError();
      _currentPage = 0;

      try {
        final result = await _estimateRepository.getEstimates(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
          status: _statusFilter,
        );
        return result.when(
          ok: (response) {
            _estimates = response;
            _totalEstimates = response.length;
            _currentPage++;
            _setState(EstimateListState.loaded);
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            _setState(EstimateListState.error);
            return Result.error(error);
          },
        );
      } catch (e) {
        _setError(e.toString());
        _setState(EstimateListState.error);
        return Result.error(Exception(e.toString()));
      }
    });

    _loadMoreEstimatesCommand = Command0(() async {
      if (!hasMoreEstimates || _state == EstimateListState.loading) {
        return Result.ok(null);
      }

      try {
        final result = await _estimateRepository.getEstimates(
          limit: _pageSize,
          offset: _currentPage * _pageSize,
          status: _statusFilter,
        );
        return result.when(
          ok: (response) {
            _estimates.addAll(response);
            _totalEstimates = _estimates.length;
            _currentPage++;
            notifyListeners();
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            return Result.error(error);
          },
        );
      } catch (e) {
        _setError(e.toString());
        return Result.error(Exception(e.toString()));
      }
    });

    _filterByStatusCommand = Command1((String? status) async {
      _statusFilter = status;
      _setState(EstimateListState.loading);
      _clearError();
      _currentPage = 0;

      try {
        final result = await _estimateRepository.getEstimates(
          limit: _pageSize,
          offset: 0,
          status: status,
        );
        return result.when(
          ok: (response) {
            _estimates = response;
            _totalEstimates = response.length;
            _currentPage = 1;
            _setState(EstimateListState.loaded);
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            _setState(EstimateListState.error);
            return Result.error(error);
          },
        );
      } catch (e) {
        _setError(e.toString());
        _setState(EstimateListState.error);
        return Result.error(Exception(e.toString()));
      }
    });

    _deleteEstimateCommand = Command1((String estimateId) async {
      try {
        final result = await _estimateRepository.deleteEstimate(estimateId);
        return result.when(
          ok: (success) {
            if (success) {
              // Remove from local list
              _estimates.removeWhere((estimate) => estimate.id == estimateId);
              _totalEstimates--;
              notifyListeners();
            }
            return Result.ok(null);
          },
          error: (error) {
            _setError(error.toString());
            return Result.error(error);
          },
        );
      } catch (e) {
        _setError(e.toString());
        return Result.error(Exception(e.toString()));
      }
    });
  }

  void _setState(EstimateListState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Public methods
  Future<void> loadEstimates() async {
    _initializeCommands();
    await _loadEstimatesCommand.execute();
  }

  Future<void> loadMoreEstimates() async {
    await _loadMoreEstimatesCommand.execute();
  }

  Future<void> filterByStatus(String? status) async {
    await _filterByStatusCommand.execute(status);
  }

  Future<void> deleteEstimate(String estimateId) async {
    await _deleteEstimateCommand.execute(estimateId);
  }

  void clearFilters() {
    _statusFilter = null;
    loadEstimates();
  }

  void refresh() {
    loadEstimates();
  }
}
