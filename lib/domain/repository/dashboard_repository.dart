import '../../model/estimates/dashboard_response_model.dart';
import '../../utils/result/result.dart';

abstract class IDashboardRepository {
  /// Get dashboard statistics with optional month filtering
  Future<Result<DashboardResponseModel>> getDashboardStats({
    String? month,
    String? compareWith,
  });

  /// Get current month dashboard statistics (default behavior)
  Future<Result<DashboardResponseModel>> getCurrentMonthStats();

  /// Get specific month dashboard statistics
  Future<Result<DashboardResponseModel>> getMonthStats(String month);

  /// Get dashboard statistics with custom comparison
  Future<Result<DashboardResponseModel>> getDashboardWithComparison({
    required String month,
    required String compareWith,
  });

  /// Cache dashboard data for offline access
  Future<Result<void>> cacheDashboardData(
    DashboardResponseModel data, {
    String? month,
    String? compareWith,
  });

  /// Get cached dashboard data
  Future<Result<DashboardResponseModel?>> getCachedDashboardData({
    String? month,
    String? compareWith,
  });

  /// Check if cached data is still valid
  bool isCacheValid(DateTime cachedAt);

  /// Clear expired cache data
  Future<Result<void>> clearExpiredCache();
}
