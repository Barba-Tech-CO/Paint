import '../../domain/repository/dashboard_repository.dart';
import '../../model/estimates/dashboard_response_model.dart';
import '../../service/dashboard_service.dart';
import '../../service/local_storage_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class DashboardRepositoryImpl implements IDashboardRepository {
  final DashboardService _dashboardService;
  final LocalStorageService _localStorageService;
  final AppLogger _logger;

  // Cache duration: 15 minutes
  static const int _cacheDurationMinutes = 15;

  DashboardRepositoryImpl(
    this._dashboardService,
    this._localStorageService,
    this._logger,
  );

  @override
  Future<Result<DashboardResponseModel>> getDashboardStats({
    String? month,
    String? compareWith,
  }) async {
    try {
      // Offline-first strategy: Always try to sync from API first
      _logger.info(
        'DashboardRepository: Attempting to sync dashboard stats from API',
      );
      final apiResult = await _dashboardService.getDashboardStats(
        month: month,
        compareWith: compareWith,
      );

      if (apiResult.isSuccess) {
        // Cache the fresh data from API
        await cacheDashboardData(
          apiResult.data,
          month: month,
          compareWith: compareWith,
        );
        _logger.info(
          'DashboardRepository: Successfully synced dashboard stats from API',
        );
        return apiResult;
      } else {
        _logger.warning(
          'DashboardRepository: API sync failed: ${apiResult.error}',
        );

        // If API fails, try to get cached data
        final cachedResult = await getCachedDashboardData(
          month: month,
          compareWith: compareWith,
        );

        if (cachedResult.isSuccess && cachedResult.data != null) {
          final cachedData = cachedResult.data!;
          _logger.info('DashboardRepository: Returning cached dashboard data');
          return Result.ok(cachedData);
        }

        return Result.error(
          Exception('No dashboard data available offline and API sync failed'),
        );
      }
    } catch (e) {
      _logger.error(
        'DashboardRepository: Error getting dashboard stats: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get dashboard statistics'),
      );
    }
  }

  @override
  Future<Result<DashboardResponseModel>> getCurrentMonthStats() async {
    return getDashboardStats();
  }

  @override
  Future<Result<DashboardResponseModel>> getMonthStats(String month) async {
    return getDashboardStats(month: month);
  }

  @override
  Future<Result<DashboardResponseModel>> getDashboardWithComparison({
    required String month,
    required String compareWith,
  }) async {
    return getDashboardStats(month: month, compareWith: compareWith);
  }

  @override
  Future<Result<void>> cacheDashboardData(
    DashboardResponseModel data, {
    String? month,
    String? compareWith,
  }) async {
    try {
      final cacheKey = _buildCacheKey(month: month, compareWith: compareWith);
      final cacheData = {
        'data': data.toJson(),
        'cached_at': DateTime.now().toIso8601String(),
        'expires_at': DateTime.now()
            .add(Duration(minutes: _cacheDurationMinutes))
            .toIso8601String(),
      };

      await _localStorageService.saveDashboardCache(cacheKey, cacheData);
      return Result.ok(null);
    } catch (e) {
      _logger.error(
        'DashboardRepository: Error caching dashboard data: $e',
        e,
      );
      return Result.error(
        Exception('Failed to cache dashboard data'),
      );
    }
  }

  @override
  Future<Result<DashboardResponseModel?>> getCachedDashboardData({
    String? month,
    String? compareWith,
  }) async {
    try {
      final cacheKey = _buildCacheKey(month: month, compareWith: compareWith);
      final cachedData = await _localStorageService.getDashboardCache(cacheKey);

      if (cachedData == null) {
        return Result.ok(null);
      }

      final cachedAt = DateTime.parse(cachedData['cached_at']);
      if (!isCacheValid(cachedAt)) {
        await _localStorageService.removeDashboardCache(cacheKey);
        return Result.ok(null);
      }

      final dashboardData = DashboardResponseModel.fromJson(cachedData['data']);

      return Result.ok(dashboardData);
    } catch (e) {
      _logger.error(
        'DashboardRepository: Error getting cached dashboard data: $e',
        e,
      );
      return Result.error(
        Exception('Failed to get cached dashboard data'),
      );
    }
  }

  @override
  bool isCacheValid(DateTime cachedAt) {
    final now = DateTime.now();
    final cacheExpiry = cachedAt.add(Duration(minutes: _cacheDurationMinutes));
    return now.isBefore(cacheExpiry);
  }

  @override
  Future<Result<void>> clearExpiredCache() async {
    try {
      await _localStorageService.clearExpiredDashboardCache();
      return Result.ok(null);
    } catch (e) {
      _logger.error(
        'DashboardRepository: Error clearing expired cache: $e',
        e,
      );
      return Result.error(
        Exception('Failed to clear expired cache'),
      );
    }
  }

  /// Build cache key for specific query parameters
  String _buildCacheKey({String? month, String? compareWith}) {
    final parts = ['dashboard'];
    if (month != null) parts.add(month);
    if (compareWith != null) parts.add(compareWith);
    return parts.join(':');
  }
}
