import 'package:dio/dio.dart';

import '../../config/app_urls.dart';
import '../../domain/repository/estimate_detail_repository.dart';
import '../../model/estimates/estimate_detail_model.dart';
import '../../service/http_service.dart';
import '../../utils/result/result.dart';

class EstimateDetailRepositoryImpl implements IEstimateDetailRepository {
  final HttpService _httpService;

  EstimateDetailRepositoryImpl(this._httpService);

  @override
  Future<Result<EstimateDetailModel>> getEstimateDetail(int estimateId) async {
    try {
      final response = await _httpService.get(
        '${AppUrls.estimatesBaseUrl}/$estimateId',
      );

      if (response.statusCode == 200) {
        final data = response.data;

        // Handle the API response format
        if (data is Map<String, dynamic>) {
          if (data['success'] == true) {
            // Check if data is in 'data' field or 'estimate' field
            final estimateData = data['data'] ?? data['estimate'];

            if (estimateData != null) {
              final estimateDetail = EstimateDetailModel.fromJson(estimateData);
              return Result.ok(estimateDetail);
            } else {
              final errorMessage = 'No estimate data found in response';
              return Result.error(
                Exception(errorMessage),
              );
            }
          } else {
            final errorMessage =
                data['message'] ?? 'Project not found or access denied';
            return Result.error(
              Exception(errorMessage),
            );
          }
        }

        return Result.error(
          Exception('Invalid response format from server'),
        );
      } else if (response.statusCode == 404) {
        return Result.error(
          Exception('Estimate not found or access denied'),
        );
      } else {
        return Result.error(
          Exception('Failed to retrieve estimate: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return Result.error(
          Exception('Estimate not found or access denied'),
        );
      } else if (e.response?.statusCode == 401) {
        return Result.error(
          Exception('Unauthorized - Invalid or expired token'),
        );
      } else {
        return Result.error(
          Exception('Network error: ${e.message}'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Unexpected error: $e'),
      );
    }
  }

  @override
  Future<Result<EstimateDetailModel>> getEstimateDetailByProjectId(
    int projectId,
  ) async {
    try {
      // In this system, projects and estimates are the same entity
      // The project ID is actually the estimate ID from the estimates table
      return await getEstimateDetail(projectId);
    } catch (e) {
      return Result.error(
        Exception('Error getting estimate by project ID: $e'),
      );
    }
  }
}
