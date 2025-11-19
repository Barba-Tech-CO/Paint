import 'dart:io';

import 'package:dio/dio.dart';

import '../config/app_urls.dart';
import '../config/dependency_injection.dart';
import '../model/quotes_data/extracted_material_list_response_model.dart';
import '../model/quotes_data/extracted_material_model.dart';
import '../model/quotes_data/material_filters_model.dart';
import '../model/quotes_data/material_filters_options_model.dart';
import '../model/quotes_data/pagination_info.dart';
import '../model/quotes_data/quote_list_response.dart';
import '../model/quotes_data/quote_model.dart';
import '../model/quotes_data/quote_response.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class QuoteService {
  final HttpService _httpService;
  late final AppLogger _logger;

  QuoteService({
    required HttpService httpService,
  }) : _httpService = httpService {
    _logger = getIt<AppLogger>();
  }

  /// Upload a quote PDF file for material extraction
  Future<Result<QuoteResponse>> uploadQuote(
    File quoteFile, {
    String? filename,
  }) async {
    try {
      // Use provided filename or extract from path
      final finalFilename = filename ?? quoteFile.path.split('/').last;

      // Validate file before creating FormData
      if (!await quoteFile.exists()) {
        return Result.error(
          Exception('File does not exist'),
        );
      }

      final fileSize = await quoteFile.length();
      if (fileSize == 0) {
        return Result.error(
          Exception('File is empty'),
        );
      }

      if (fileSize > 200 * 1024 * 1024) {
        // 200MB
        return Result.error(
          Exception('File size exceeds 200MB limit'),
        );
      }

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        // Backend expects field name `quote` (docs reference `pdf`), keep aligned with API request class
        'quote': await MultipartFile.fromFile(
          quoteFile.path,
          filename: finalFilename,
        ),
      });

      final response = await _httpService.post(
        AppUrls.materialsUploadUrl,
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final uploadResponse = QuoteResponse.fromJson(response.data);
        return Result.ok(uploadResponse);
      } else {
        return Result.error(
          Exception('Upload failed with status: ${response.statusCode}'),
        );
      }
    } on DioException catch (e) {
      _logger.error('QuoteService: DioException during quote upload', e);
      // Handle specific HTTP status codes
      switch (e.response?.statusCode) {
        case 400:
          return Result.error(
            Exception(
              'Invalid request: Please check your file format and try again',
            ),
          );
        case 401:
          return Result.error(
            Exception('Authentication failed: Please log in again'),
          );
        case 403:
          return Result.error(
            Exception(
              'Access denied: You do not have permission to upload files',
            ),
          );
        case 413:
          return Result.error(
            Exception('File too large: Maximum size is 200MB'),
          );
        case 422:
          // Handle validation errors specifically
          final responseData = e.response?.data;

          if (responseData is Map<String, dynamic>) {
            final errors =
                responseData['errors'] ??
                responseData['message'] ??
                'Validation failed';

            // Try to extract specific validation error details
            if (responseData['errors'] is Map<String, dynamic>) {
              final errorDetails = <String>[];
              for (final entry in responseData['errors'].entries) {
                errorDetails.add('${entry.key}: ${entry.value}');
              }
              return Result.error(
                Exception('Validation error: ${errorDetails.join(', ')}'),
              );
            }

            return Result.error(
              Exception('Validation error: $errors'),
            );
          }
          return Result.error(
            Exception('Validation error: Invalid request format'),
          );
        case 500:
          return Result.error(
            Exception('Server error: Please try again later'),
          );
        case 503:
          return Result.error(
            Exception('Service unavailable: Please try again later'),
          );
        default:
          // Handle network errors
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            return Result.error(
              Exception(
                'Connection timeout: Please check your internet connection',
              ),
            );
          } else if (e.type == DioExceptionType.connectionError) {
            return Result.error(
              Exception(
                'Connection error: Please check your internet connection',
              ),
            );
          }

          return Result.error(
            Exception('Error uploading PDF: ${e.message ?? 'Unknown error'}'),
          );
      }
    } catch (e) {
      _logger.error('QuoteService: Unexpected error during quote upload', e);
      return Result.error(
        Exception('Unexpected error uploading PDF'),
      );
    }
  }

  /// Get list of uploaded quotes with pagination and filters
  Future<Result<QuoteListResponse>> getQuotes({
    String? status,
    int limit = 10,
    int page = 1,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'page': page,
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpService.get(
        AppUrls.materialsUploadsUrl,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        try {
          final listResponse = QuoteListResponse.fromJson(response.data);
          return Result.ok(listResponse);
        } catch (e) {
          _logger.error('QuoteService: Failed to parse getQuotes response', e);
          return Result.error(
            Exception('Failed to parse response'),
          );
        }
      } else {
        return Result.error(
          Exception('Failed to get uploads: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error('QuoteService: Error getting quotes', e);
      return Result.error(
        Exception('Error getting uploads'),
      );
    }
  }

  /// Check the processing status of a specific PDF upload
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId) async {
    try {
      final response = await _httpService.get(
        '${AppUrls.materialsStatusUrl}/$quoteId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final quote = QuoteModel.fromJson(data['upload']);
        return Result.ok(quote);
      } else {
        return Result.error(
          Exception('Failed to get status: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error(
        'QuoteService: Error getting quote status for ID $quoteId',
        e,
      );
      return Result.error(
        Exception('Error getting upload status'),
      );
    }
  }

  /// Update display name of an uploaded PDF
  Future<Result<QuoteModel>> updateQuote(
    int quoteId,
    String displayName,
  ) async {
    try {
      final response = await _httpService.put(
        '${AppUrls.materialsUpdateUrl}/$quoteId',
        data: {'display_name': displayName},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final quote = QuoteModel.fromJson(data['upload']);
        return Result.ok(quote);
      } else {
        return Result.error(
          Exception('Failed to update upload: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error('QuoteService: Error updating quote ID $quoteId', e);
      return Result.error(
        Exception('Error updating upload'),
      );
    }
  }

  /// Delete an uploaded PDF and all extracted materials
  Future<Result<bool>> deleteQuote(int quoteId) async {
    try {
      final response = await _httpService.delete(
        '${AppUrls.materialsDeleteUrl}/$quoteId',
      );

      if (response.statusCode == 200) {
        return Result.ok(true);
      } else {
        return Result.error(
          Exception('Failed to delete upload: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error('QuoteService: Error deleting quote ID $quoteId', e);
      return Result.error(
        Exception('Error deleting upload'),
      );
    }
  }

  /// Get extracted materials with filtering and pagination
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams() ?? <String, dynamic>{};

      // Busca todos os materiais fazendo múltiplas chamadas
      final allMaterials = <ExtractedMaterialModel>[];
      int currentPage = 1;
      bool hasMorePages = true;

      while (hasMorePages) {
        queryParams['page'] = currentPage;

        final response = await _httpService.get(
          AppUrls.materialsExtractedUrl,
          queryParameters: queryParams,
        );

        if (response.statusCode == 200) {
          final listResponse = ExtractedMaterialListResponse.fromJson(
            response.data,
          );

          allMaterials.addAll(listResponse.materials);

          // Verifica se há mais páginas
          final pagination = listResponse.pagination;
          hasMorePages = currentPage < pagination.lastPage;
          currentPage++;
        } else {
          return Result.error(
            Exception('Failed to get materials: ${response.statusCode}'),
          );
        }
      }

      // Cria uma resposta com todos os materiais
      final allMaterialsResponse = ExtractedMaterialListResponse(
        success: true,
        materials: allMaterials,
        pagination: PaginationInfo(
          total: allMaterials.length,
          perPage: 20,
          currentPage: 1,
          lastPage: 1,
          from: 1,
          to: allMaterials.length,
        ),
        filtersApplied: queryParams,
      );

      return Result.ok(allMaterialsResponse);
    } catch (e) {
      _logger.error('QuoteService: Error getting extracted materials', e);
      return Result.error(
        Exception('Error getting extracted materials'),
      );
    }
  }

  /// Get a specific extracted material by ID
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(
    int materialId,
  ) async {
    try {
      final response = await _httpService.get(
        '${AppUrls.materialsExtractedUrl}/$materialId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final material = ExtractedMaterialModel.fromJson(data['material']);
        return Result.ok(material);
      } else {
        return Result.error(
          Exception('Failed to get material: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error(
        'QuoteService: Error getting extracted material ID $materialId',
        e,
      );
      return Result.error(
        Exception('Error getting extracted material'),
      );
    }
  }

  /// Get available filter options for extracted materials
  Future<Result<MaterialFiltersOptions>> getFilterOptions() async {
    try {
      final response = await _httpService.get(AppUrls.materialsFiltersUrl);

      if (response.statusCode == 200) {
        final options = MaterialFiltersOptions.fromJson(response.data);
        return Result.ok(options);
      } else {
        return Result.error(
          Exception('Failed to get filter options: ${response.statusCode}'),
        );
      }
    } catch (e) {
      _logger.error('QuoteService: Error getting filter options', e);
      return Result.error(
        Exception('Error getting filter options'),
      );
    }
  }

  /// Poll quote upload status until processing is complete
  Future<Result<QuoteModel>> pollQuoteStatus(
    int quoteId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final startTime = DateTime.now();
    int attemptCount = 0;
    const int maxAttempts = 30;

    // Track status changes to detect stuck status
    String? lastStatus;
    DateTime? lastStatusChangeTime;
    const Duration maxStatusStuckTime = Duration(
      minutes: 2,
    ); // Stop if status doesn't change for 2 minutes
    const Duration initialProcessingTimeout = Duration(
      seconds: 30,
    ); // Give backend 30 seconds to start processing

    // Add initial delay to allow backend processing to start
    await Future.delayed(
      const Duration(seconds: 3),
    );

    while (DateTime.now().difference(startTime) < timeout &&
        attemptCount < maxAttempts) {
      attemptCount++;

      try {
        final statusResult = await getQuoteStatus(quoteId);

        if (statusResult is Ok<QuoteModel>) {
          final quote = statusResult.value;
          final currentStatus = quote.status.value;

          // Track status changes
          if (lastStatus != currentStatus) {
            lastStatus = currentStatus;
            lastStatusChangeTime = DateTime.now();
          }

          // Check if processing is complete
          if (quote.isCompleted || quote.isFailed || quote.isError) {
            return Result.ok(quote);
          }

          // Check if status has been stuck for too long
          if (lastStatusChangeTime != null &&
              DateTime.now().difference(lastStatusChangeTime) >
                  maxStatusStuckTime) {
            return Result.error(
              Exception(
                'Quote processing appears to be stuck on status: $currentStatus',
              ),
            );
          }

          // Check if initial processing timeout has been reached (status still pending after 30 seconds)
          if (currentStatus == 'pending' &&
              DateTime.now().difference(startTime) > initialProcessingTimeout) {
            return Result.error(
              Exception(
                'Quote upload accepted but backend processing appears to be delayed or stuck. Please try again later.',
              ),
            );
          }

          // If still pending/processing, continue polling
          if (quote.isPending || quote.isProcessing) {
            // Wait before next check
            await Future.delayed(interval);
            continue;
          }
        } else {
          // If we get an error, don't fail immediately
          // This prevents the loop from breaking on temporary network issues
          final error = statusResult.asError.error;

          // Only fail immediately on critical errors (401, 403, 404)
          if (error.toString().contains('401') ||
              error.toString().contains('403') ||
              error.toString().contains('404')) {
            return statusResult;
          }

          // For other errors, wait and retry
          await Future.delayed(interval);
          continue;
        }
      } catch (e) {
        _logger.error(
          'QuoteService: Exception during status polling for quote ID $quoteId',
          e,
        );
        // Only fail on critical exceptions
        if (e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          return Result.error(
            Exception('Network error during status polling'),
          );
        }

        // For other exceptions, wait and retry
        await Future.delayed(interval);
        continue;
      }
    }

    // If we reach here, either timeout or max attempts reached
    if (attemptCount >= maxAttempts) {
      return Result.error(
        Exception(
          'Quote processing exceeded maximum attempts ($maxAttempts) after ${timeout.inMinutes} minutes',
        ),
      );
    }

    return Result.error(
      Exception(
        'Quote processing timeout after ${timeout.inMinutes} minutes',
      ),
    );
  }
}
