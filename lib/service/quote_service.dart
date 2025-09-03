import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../model/models.dart';
import '../model/quotes_data/extracted_material_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class QuoteService {
  final HttpService _httpService;

  QuoteService({
    required HttpService httpService,
  }) : _httpService = httpService;

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
        return Result.error(Exception('File does not exist'));
      }

      final fileSize = await quoteFile.length();
      if (fileSize == 0) {
        return Result.error(Exception('File is empty'));
      }

      if (fileSize > 25 * 1024 * 1024) {
        // 25MB
        return Result.error(Exception('File size exceeds 25MB limit'));
      }

      // Create FormData for multipart upload
      final formData = FormData.fromMap({
        'quote': await MultipartFile.fromFile(
          quoteFile.path,
          filename: finalFilename,
        ),
      });

      // Log essential info for debugging
      log('DEBUG: uploadQuote - File: $finalFilename, Size: $fileSize bytes');

      final response = await _httpService.post(
        '/materials/upload',
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
      // Handle Dio-specific errors with essential detail
      log('DEBUG: uploadQuote - Error ${e.response?.statusCode}: ${e.message}');

      if (e.response?.statusCode == 422) {
        // Handle validation errors specifically
        final responseData = e.response?.data;
        log('DEBUG: uploadQuote - Validation error details: $responseData');

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
      } else if (e.response?.statusCode == 401) {
        return Result.error(
          Exception('Authentication failed: Please log in again'),
        );
      } else if (e.response?.statusCode == 403) {
        return Result.error(
          Exception(
            'Access denied: You do not have permission to upload files',
          ),
        );
      } else if (e.response?.statusCode == 413) {
        return Result.error(
          Exception('File too large: Maximum size is 25MB'),
        );
      }

      return Result.error(
        Exception('Error uploading PDF: ${e.message}'),
      );
    } catch (e) {
      return Result.error(
        Exception('Error uploading PDF: $e'),
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

      log('DEBUG: getQuotes - queryParams: $queryParams');
      log('DEBUG: getQuotes - endpoint: /materials/uploads');

      final response = await _httpService.get(
        '/materials/uploads',
        queryParameters: queryParams,
      );

      log('DEBUG: getQuotes - response.statusCode: ${response.statusCode}');
      log('DEBUG: getQuotes - response.data: ${response.data}');
      log(
        'DEBUG: getQuotes - response.data type: ${response.data.runtimeType}',
      );

      if (response.statusCode == 200) {
        try {
          // Log the structure of the response data
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            log('DEBUG: getQuotes - data keys: ${data.keys.toList()}');
            if (data['data'] is Map<String, dynamic>) {
              final innerData = data['data'] as Map<String, dynamic>;
              log(
                'DEBUG: getQuotes - inner data keys: ${innerData.keys.toList()}',
              );
              if (innerData['uploads'] != null) {
                log(
                  'DEBUG: getQuotes - uploads type: ${innerData['uploads'].runtimeType}',
                );
                if (innerData['uploads'] is Map<String, dynamic>) {
                  final uploads = innerData['uploads'] as Map<String, dynamic>;
                  log(
                    'DEBUG: getQuotes - uploads keys: ${uploads.keys.toList()}',
                  );
                }
              }
            }
          }

          final listResponse = QuoteListResponse.fromJson(response.data);
          return Result.ok(listResponse);
        } catch (e) {
          log('DEBUG: getQuotes - Error parsing response: $e');
          log('DEBUG: getQuotes - Response data: ${response.data}');
          return Result.error(
            Exception('Failed to parse response: $e'),
          );
        }
      } else {
        return Result.error(
          Exception('Failed to get uploads: ${response.statusCode}'),
        );
      }
    } catch (e) {
      log('DEBUG: getQuotes - error: $e');
      return Result.error(
        Exception('Error getting uploads: $e'),
      );
    }
  }

  /// Check the processing status of a specific PDF upload
  Future<Result<QuoteModel>> getQuoteStatus(int quoteId) async {
    try {
      final response = await _httpService.get('/materials/status/$quoteId');

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
      return Result.error(
        Exception('Error getting upload status: $e'),
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
        '/materials/update/$quoteId',
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
      return Result.error(
        Exception('Error updating upload: $e'),
      );
    }
  }

  /// Delete an uploaded PDF and all extracted materials
  Future<Result<bool>> deleteQuote(int quoteId) async {
    try {
      final response = await _httpService.delete('/materials/delete/$quoteId');

      if (response.statusCode == 200) {
        return Result.ok(true);
      } else {
        return Result.error(
          Exception('Failed to delete upload: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error deleting upload: $e'),
      );
    }
  }

  /// Get extracted materials with filtering and pagination
  Future<Result<ExtractedMaterialListResponse>> getExtractedMaterials({
    MaterialFilters? filters,
  }) async {
    try {
      final queryParams = filters?.toQueryParams() ?? <String, dynamic>{};

      final response = await _httpService.get(
        '/materials/extracted',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final listResponse = ExtractedMaterialListResponse.fromJson(
          response.data,
        );
        return Result.ok(listResponse);
      } else {
        return Result.error(
          Exception('Failed to get materials: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error getting extracted materials: $e'),
      );
    }
  }

  /// Get a specific extracted material by ID
  Future<Result<ExtractedMaterialModel>> getExtractedMaterial(
    int materialId,
  ) async {
    try {
      final response = await _httpService.get(
        '/materials/extracted/$materialId',
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
      return Result.error(
        Exception('Error getting extracted material: $e'),
      );
    }
  }

  /// Get available filter options for extracted materials
  Future<Result<MaterialFiltersOptions>> getFilterOptions() async {
    try {
      final response = await _httpService.get('/materials/filters');

      if (response.statusCode == 200) {
        final options = MaterialFiltersOptions.fromJson(response.data);
        return Result.ok(options);
      } else {
        return Result.error(
          Exception('Failed to get filter options: ${response.statusCode}'),
        );
      }
    } catch (e) {
      return Result.error(
        Exception('Error getting filter options: $e'),
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
    log(
      'DEBUG: Waiting 3 seconds before starting status polling for quote: $quoteId',
    );
    await Future.delayed(const Duration(seconds: 3));

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
            log(
              'DEBUG: Quote $quoteId status changed to: $currentStatus',
            );
          }

          // Log progress every 5 attempts to avoid spam
          if (attemptCount % 5 == 0) {
            log(
              'DEBUG: Quote $quoteId status check attempt $attemptCount - Status: $currentStatus',
            );
          }

          // Check if processing is complete
          if (quote.isCompleted || quote.isFailed || quote.isError) {
            log(
              'DEBUG: Quote $quoteId processing completed with status: $currentStatus',
            );
            return Result.ok(quote);
          }

          // Check if status has been stuck for too long
          if (lastStatusChangeTime != null &&
              DateTime.now().difference(lastStatusChangeTime) >
                  maxStatusStuckTime) {
            log(
              'DEBUG: Quote $quoteId status stuck on "$currentStatus" for ${maxStatusStuckTime.inMinutes} minutes, stopping polling',
            );
            return Result.error(
              Exception(
                'Quote processing appears to be stuck on status: $currentStatus',
              ),
            );
          }

          // Check if initial processing timeout has been reached (status still pending after 30 seconds)
          if (currentStatus == 'pending' &&
              DateTime.now().difference(startTime) > initialProcessingTimeout) {
            log(
              'DEBUG: Quote $quoteId still pending after ${initialProcessingTimeout.inSeconds} seconds, backend may not be processing',
            );
            log(
              'DEBUG: Total time elapsed: ${DateTime.now().difference(startTime).inSeconds} seconds',
            );

            // Check if this is a systemic issue by looking at other quotes
            try {
              final otherQuotesResponse = await _httpService.get(
                '/materials/uploads?limit=10',
              );
              if (otherQuotesResponse.statusCode == 200) {
                final data = otherQuotesResponse.data;
                if (data is Map<String, dynamic> && data['data'] != null) {
                  final quotes = data['data']['uploads'] as List?;
                  if (quotes != null) {
                    int pendingCount = 0;
                    int totalCount = quotes.length;
                    for (final quote in quotes) {
                      if (quote['status'] == 'pending') {
                        pendingCount++;
                      }
                    }
                    log(
                      'DEBUG: Found $pendingCount pending quotes out of $totalCount total quotes',
                    );
                    if (pendingCount > totalCount * 0.5) {
                      log(
                        'DEBUG: High percentage of pending quotes suggests backend processing issue',
                      );
                    }
                  }
                }
              }
            } catch (e) {
              log('DEBUG: Could not check other quotes status: $e');
            }

            return Result.error(
              Exception(
                'Quote upload accepted but backend processing appears to be delayed or stuck. Please try again later.',
              ),
            );
          }

          // Warning when approaching timeout
          if (currentStatus == 'pending' &&
              DateTime.now().difference(startTime) > Duration(seconds: 20)) {
            log(
              'DEBUG: WARNING: Quote $quoteId approaching timeout (${initialProcessingTimeout.inSeconds}s) - Status: $currentStatus',
            );
          }

          // If still pending/processing, continue polling
          if (quote.isPending || quote.isProcessing) {
            // Log the current polling state for debugging
            if (attemptCount % 3 == 0) {
              // Log every 3rd attempt to avoid spam
              log(
                'DEBUG: Quote $quoteId attempt $attemptCount - Status: $currentStatus, Time elapsed: ${DateTime.now().difference(startTime).inSeconds}s',
              );
            }

            // Wait before next check
            await Future.delayed(interval);
            continue;
          }

          // If we reach here, status is unknown, log and continue
          log(
            'DEBUG: Quote $quoteId has unknown status: $currentStatus',
          );
        } else {
          // If we get an error, log it but don't fail immediately
          // This prevents the loop from breaking on temporary network issues
          final error = statusResult.asError.error;
          log(
            'DEBUG: Quote $quoteId status check attempt $attemptCount failed: $error',
          );

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
        log(
          'DEBUG: Quote $quoteId status check attempt $attemptCount threw exception: $e',
        );

        // Only fail on critical exceptions
        if (e.toString().contains('SocketException') ||
            e.toString().contains('TimeoutException')) {
          return Result.error(
            Exception('Network error during status polling: $e'),
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
    } else {
      return Result.error(
        Exception(
          'Quote processing timeout after ${timeout.inMinutes} minutes',
        ),
      );
    }
  }
}
