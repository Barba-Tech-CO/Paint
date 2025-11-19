import '../../domain/repository/dashboard_repository.dart';
import '../../model/estimates/dashboard_response_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class DashboardFinancialUseCase {
  final IDashboardRepository _dashboardRepository;
  final AppLogger _logger;

  DashboardFinancialUseCase(this._dashboardRepository, this._logger);

  /// Get current month financial statistics
  Future<Result<DashboardResponseModel>> getCurrentMonthFinancialStats() async {
    try {
      return await _dashboardRepository.getCurrentMonthStats();
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting current month financial stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get current month financial statistics'),
      );
    }
  }

  /// Get financial statistics for specific month
  Future<Result<DashboardResponseModel>> getMonthFinancialStats(
    String month,
  ) async {
    try {
      _validateMonthFormat(month);
      return await _dashboardRepository.getMonthStats(month);
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting month financial stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get month financial statistics'),
      );
    }
  }

  /// Get financial statistics with custom comparison
  Future<Result<DashboardResponseModel>> getFinancialStatsWithComparison({
    required String month,
    required String compareWith,
  }) async {
    try {
      _validateMonthFormat(month);
      _validateMonthFormat(compareWith);
      return await _dashboardRepository.getDashboardWithComparison(
        month: month,
        compareWith: compareWith,
      );
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting financial stats with comparison: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get financial statistics with comparison'),
      );
    }
  }

  /// Get previous month financial statistics
  Future<Result<DashboardResponseModel>>
  getPreviousMonthFinancialStats() async {
    try {
      final now = DateTime.now();
      final previousMonth = DateTime(now.year, now.month - 1);
      final monthString =
          '${previousMonth.year}-${previousMonth.month.toString().padLeft(2, '0')}';

      return await _dashboardRepository.getMonthStats(monthString);
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting previous month financial stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get previous month financial statistics'),
      );
    }
  }

  /// Get financial statistics with growth analysis
  Future<Result<DashboardResponseModel>> getFinancialStatsWithGrowth({
    String? month,
    String? compareWith,
  }) async {
    try {
      if (month != null) _validateMonthFormat(month);
      if (compareWith != null) _validateMonthFormat(compareWith);

      return await _dashboardRepository.getDashboardStats(
        month: month,
        compareWith: compareWith,
      );
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting financial stats with growth: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get financial statistics with growth'),
      );
    }
  }

  /// Get cached financial statistics
  Future<Result<DashboardResponseModel?>> getCachedFinancialStats({
    String? month,
    String? compareWith,
  }) async {
    try {
      return await _dashboardRepository.getCachedDashboardData(
        month: month,
        compareWith: compareWith,
      );
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error getting cached financial stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get cached financial statistics'),
      );
    }
  }

  /// Cache financial statistics
  Future<Result<void>> cacheFinancialStats(
    DashboardResponseModel data, {
    String? month,
    String? compareWith,
  }) async {
    try {
      return await _dashboardRepository.cacheDashboardData(
        data,
        month: month,
        compareWith: compareWith,
      );
    } catch (e) {
      _logger.error(
        '[DashboardFinancialUseCase] Error caching financial stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to cache financial statistics'),
      );
    }
  }

  /// Validate month format (YYYY-MM)
  void _validateMonthFormat(String month) {
    final regex = RegExp(r'^\d{4}-\d{2}$');
    if (!regex.hasMatch(month)) {
      throw ArgumentError(
        'Invalid month format. Use YYYY-MM format (e.g., 2025-09)',
      );
    }
  }

  /// Get month display name for UI
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
      _logger.warning(
        '[DashboardFinancialUseCase] Error parsing month year: $monthYear',
      );
    }

    return monthYear;
  }

  /// Format currency for display
  String formatCurrency(double? amount) {
    if (amount == null) return '\$0.00';
    return '\$${amount.toStringAsFixed(2)}';
  }

  /// Format percentage for display
  String formatPercentage(double? percentage) {
    if (percentage == null) return '0.0%';
    return '${percentage.toStringAsFixed(1)}%';
  }

  /// Check if growth is positive
  bool isGrowthPositive(double? percentage) {
    return (percentage ?? 0) >= 0;
  }
}
