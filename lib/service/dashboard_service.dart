import 'package:dio/dio.dart';

import '../config/app_urls.dart';
import '../model/estimates/dashboard_response_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class DashboardService {
  final HttpService _httpService;

  DashboardService(this._httpService);

  /// Get dashboard statistics with optional month filtering
  Future<Result<DashboardResponseModel>> getDashboardStats({
    String? month,
    String? compareWith,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (month != null) queryParams['month'] = month;
      if (compareWith != null) queryParams['compare_with'] = compareWith;

      final response = await _httpService.get(
        '${AppUrls.estimatesBaseUrl}/dashboard',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final dashboardData = DashboardResponseModel.fromJson(response.data);
        return Result.ok(dashboardData);
      } else {
        return Result.error(
          Exception('Failed to load dashboard: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      return Result.error(
        Exception('Network error loading dashboard: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Exception('Error loading dashboard: $e'),
      );
    }
  }

  /// Get current month dashboard statistics (default behavior)
  Future<Result<DashboardResponseModel>> getCurrentMonthStats() async {
    return getDashboardStats();
  }

  /// Get specific month dashboard statistics
  Future<Result<DashboardResponseModel>> getMonthStats(String month) async {
    return getDashboardStats(month: month);
  }

  /// Get dashboard statistics with custom comparison
  Future<Result<DashboardResponseModel>> getDashboardWithComparison({
    required String month,
    required String compareWith,
  }) async {
    return getDashboardStats(month: month, compareWith: compareWith);
  }
}
