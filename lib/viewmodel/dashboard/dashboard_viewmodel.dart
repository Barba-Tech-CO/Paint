import 'package:flutter/foundation.dart';

import '../../config/dependency_injection.dart';
import '../../domain/repository/dashboard_repository.dart';
import '../../model/estimates/dashboard_response_model.dart';
import '../../model/estimates/dashboard_stats_model.dart';
import '../../model/estimates/growth_model.dart';
import '../../model/estimates/monthly_stats_model.dart';
import '../../model/estimates/requiring_attention_model.dart';
import '../../use_case/dashboard/dashboard_financial_use_case.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  final IDashboardRepository _dashboardRepository;
  final DashboardFinancialUseCase _financialUseCase;
  late final AppLogger _logger;

  // State
  DashboardState _state = DashboardState.initial;
  DashboardState get state => _state;

  // Data
  DashboardResponseModel? _dashboardData;
  DashboardResponseModel? get dashboardData => _dashboardData;

  // Error handling
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Getters
  bool get isLoading => _state == DashboardState.loading;
  bool get hasError => _state == DashboardState.error;
  bool get hasData => _dashboardData != null;

  // Current month data getters
  DashboardStatsModel? get statistics => _dashboardData?.data.statistics;
  MonthlyStatsModel? get currentMonth => _dashboardData?.data.currentMonth;
  MonthlyStatsModel? get previousMonth => _dashboardData?.data.previousMonth;
  GrowthModel? get growth => _dashboardData?.data.growth;
  List<RequiringAttentionModel> get requiringAttention =>
      _dashboardData?.data.requiringAttention ?? [];
  int get requiringAttentionCount =>
      _dashboardData?.data.requiringAttentionCount ?? 0;

  DashboardViewModel(this._dashboardRepository, this._financialUseCase) {
    _logger = getIt<AppLogger>();
  }

  /// Initialize dashboard data
  Future<void> initialize() async {
    await loadDashboardStats();
  }

  /// Load dashboard statistics for current month
  Future<Result<void>> loadDashboardStats() async {
    return await _loadDashboardStats();
  }

  /// Load dashboard statistics for specific month
  Future<Result<void>> loadMonthStats(String month) async {
    return await _loadDashboardStats(month: month);
  }

  /// Load dashboard statistics with custom comparison
  Future<Result<void>> loadDashboardWithComparison({
    required String month,
    required String compareWith,
  }) async {
    return await _loadDashboardStats(month: month, compareWith: compareWith);
  }

  /// Internal method to load dashboard statistics
  Future<Result<void>> _loadDashboardStats({
    String? month,
    String? compareWith,
  }) async {
    try {
      _setState(DashboardState.loading);
      _clearError();

      final result = await _dashboardRepository.getDashboardStats(
        month: month,
        compareWith: compareWith,
      );

      return result.when(
        ok: (data) {
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DashboardViewModel] Error loading dashboard data: $error',
          );
          _setError('Failed to load dashboard data');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error(
        '[DashboardViewModel] Exception loading dashboard stats: $e',
      );
      _setError('Unexpected error occurred');
      _setState(DashboardState.error);
      return Result.error(
        Exception('Failed to load dashboard data'),
      );
    }
  }

  /// Refresh dashboard data
  Future<Result<void>> refresh() async {
    return await loadDashboardStats();
  }

  /// Load financial statistics for current month
  Future<Result<void>> loadCurrentMonthFinancialStats() async {
    try {
      _setState(DashboardState.loading);
      _clearError();

      final result = await _financialUseCase.getCurrentMonthFinancialStats();

      return result.when(
        ok: (data) {
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DashboardViewModel] Error loading current month financial data: $error',
          );
          _setError('Failed to load current month financial data');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error(
        '[DashboardViewModel] Exception loading current month financial stats: $e',
      );
      _setError('Unexpected error occurred');
      _setState(DashboardState.error);
      return Result.error(
        Exception('Failed to load current month financial data'),
      );
    }
  }

  /// Load financial statistics for specific month
  Future<Result<void>> loadMonthFinancialStats(String month) async {
    try {
      _setState(DashboardState.loading);
      _clearError();

      final result = await _financialUseCase.getMonthFinancialStats(month);

      return result.when(
        ok: (data) {
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DashboardViewModel] Error loading month financial data: $error',
          );
          _setError('Failed to load month financial data');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error(
        '[DashboardViewModel] Exception loading month financial stats: $e',
      );
      _setError('Unexpected error occurred');
      _setState(DashboardState.error);
      return Result.error(
        Exception('Failed to load month financial data'),
      );
    }
  }

  /// Load financial statistics with comparison
  Future<Result<void>> loadFinancialStatsWithComparison({
    required String month,
    required String compareWith,
  }) async {
    try {
      _setState(DashboardState.loading);
      _clearError();

      final result = await _financialUseCase.getFinancialStatsWithComparison(
        month: month,
        compareWith: compareWith,
      );

      return result.when(
        ok: (data) {
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DashboardViewModel] Error loading financial comparison data: $error',
          );
          _setError('Failed to load financial comparison data');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error(
        '[DashboardViewModel] Exception loading financial comparison stats: $e',
      );
      _setError('Unexpected error occurred');
      _setState(DashboardState.error);
      return Result.error(
        Exception('Failed to load financial comparison data'),
      );
    }
  }

  /// Load previous month financial statistics
  Future<Result<void>> loadPreviousMonthFinancialStats() async {
    try {
      _setState(DashboardState.loading);
      _clearError();

      final result = await _financialUseCase.getPreviousMonthFinancialStats();

      return result.when(
        ok: (data) {
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          _logger.error(
            '[DashboardViewModel] Error loading previous month financial data: $error',
          );
          _setError('Failed to load previous month financial data');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      _logger.error(
        '[DashboardViewModel] Exception loading previous month financial stats: $e',
      );
      _setError('Unexpected error occurred');
      _setState(DashboardState.error);
      return Result.error(
        Exception('Failed to load previous month financial data'),
      );
    }
  }

  /// Get formatted revenue string
  String getFormattedRevenue(double? revenue) {
    if (revenue == null) return '\$0.00';
    return '\$${revenue.toStringAsFixed(2)}';
  }

  /// Get formatted percentage string
  String getFormattedPercentage(double? percentage) {
    if (percentage == null) return '0.0%';
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Get formatted currency using financial use case
  String getFormattedCurrency(double? amount) {
    return _financialUseCase.formatCurrency(amount);
  }

  /// Get formatted percentage using financial use case
  String getFormattedPercentageFromUseCase(double? percentage) {
    return _financialUseCase.formatPercentage(percentage);
  }

  /// Get month display name using financial use case
  String getMonthDisplayNameFromUseCase(String? monthYear) {
    return _financialUseCase.getMonthDisplayName(monthYear);
  }

  /// Get growth indicator (positive/negative)
  bool get isRevenueGrowthPositive => (growth?.revenuePercentage ?? 0) >= 0;
  bool get isEstimatesGrowthPositive => (growth?.estimatesPercentage ?? 0) >= 0;

  /// Get month display name
  String getMonthDisplayName(String? monthYear) {
    if (monthYear == null || monthYear.isEmpty) return 'Current Month';

    try {
      final parts = monthYear.split('-');
      if (parts.length == 2) {
        final year = parts[0];
        final month = int.parse(parts[1]);
        final monthNames = [
          '',
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${monthNames[month]} $year';
      }
    } catch (e) {
      // Handle parsing error silently
    }

    return monthYear;
  }

  /// Check if data is stale and needs refresh
  bool get needsRefresh {
    if (_dashboardData == null) return true;
    // Add logic to check if data is older than 15 minutes
    return true; // For now, always allow refresh
  }

  /// Clear error state
  void _clearError() {
    _errorMessage = null;
  }

  /// Set error state
  void _setError(String message) {
    _errorMessage = message;
  }

  /// Set state and notify listeners
  void _setState(DashboardState newState) {
    _state = newState;
    notifyListeners();
  }
}
