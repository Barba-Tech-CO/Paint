import 'dart:developer';

import 'package:flutter/foundation.dart';

import '../../domain/repository/dashboard_repository.dart';
import '../../model/estimates/dashboard_response_model.dart';
import '../../model/estimates/dashboard_stats_model.dart';
import '../../model/estimates/growth_model.dart';
import '../../model/estimates/monthly_stats_model.dart';
import '../../model/estimates/requiring_attention_model.dart';
import '../../utils/result/result.dart';

enum DashboardState { initial, loading, loaded, error }

class DashboardViewModel extends ChangeNotifier {
  final IDashboardRepository _dashboardRepository;

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

  DashboardViewModel(this._dashboardRepository);

  /// Initialize dashboard data
  Future<void> initialize() async {
    log('[DASHBOARD] Initializing DashboardViewModel...');
    try {
      await loadDashboardStats();
      log('[DASHBOARD] DashboardViewModel initialized successfully');
    } catch (e) {
      log('[DASHBOARD] Error initializing DashboardViewModel: $e');
    }
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
      log(
        '[DASHBOARD] Loading dashboard stats for month: $month, compareWith: $compareWith',
      );
      _setState(DashboardState.loading);
      _clearError();

      final result = await _dashboardRepository.getDashboardStats(
        month: month,
        compareWith: compareWith,
      );

      return result.when(
        ok: (data) {
          log('[DASHBOARD] Dashboard data loaded successfully');
          _dashboardData = data;
          _setState(DashboardState.loaded);
          return Result.ok(null);
        },
        error: (error) {
          log('[DASHBOARD] Error loading dashboard data: $error');
          _setError('Failed to load dashboard data: ${error.toString()}');
          _setState(DashboardState.error);
          return Result.error(error);
        },
      );
    } catch (e) {
      log('[DASHBOARD] Exception loading dashboard stats: $e');
      _setError('Unexpected error: ${e.toString()}');
      _setState(DashboardState.error);
      return Result.error(Exception('Unexpected error: $e'));
    }
  }

  /// Refresh dashboard data
  Future<Result<void>> refresh() async {
    return await loadDashboardStats();
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
      log('[DASHBOARD] Error parsing month year: $monthYear');
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

  @override
  void dispose() {
    super.dispose();
  }
}
