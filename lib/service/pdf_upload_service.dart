import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';

import '../model/models.dart';
import '../model/pdf_upload/extracted_material_model.dart';
import '../utils/result/result.dart';
import 'http_service.dart';

class QuoteUploadService {
  final HttpService _httpService;

  QuoteUploadService({
    required HttpService httpService,
  }) : _httpService = httpService;

  /// Upload a quote PDF file for material extraction
  Future<Result<PdfUploadResponse>> uploadQuote(
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
        'pdf': await MultipartFile.fromFile(
          quoteFile.path,
          filename: finalFilename,
        ),
      });

      // Log essential info for debugging
      log('DEBUG: uploadQuote - File: $finalFilename, Size: ${fileSize} bytes');

      final response = await _httpService.post(
        '/materials/upload',
        data: formData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final uploadResponse = PdfUploadResponse.fromJson(response.data);
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
  Future<Result<PdfUploadListResponse>> getQuotes({
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

          final listResponse = PdfUploadListResponse.fromJson(response.data);
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
  Future<Result<PdfUploadModel>> getUploadStatus(int uploadId) async {
    try {
      final response = await _httpService.get('/materials/status/$uploadId');

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final upload = PdfUploadModel.fromJson(data['upload']);
        return Result.ok(upload);
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
  Future<Result<PdfUploadModel>> updateUpload(
    int uploadId,
    String displayName,
  ) async {
    try {
      final response = await _httpService.put(
        '/materials/update/$uploadId',
        data: {'display_name': displayName},
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final upload = PdfUploadModel.fromJson(data['upload']);
        return Result.ok(upload);
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
  Future<Result<bool>> deleteUpload(int uploadId) async {
    try {
      final response = await _httpService.delete('/materials/delete/$uploadId');

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
  Future<Result<PdfUploadModel>> pollQuoteStatus(
    int uploadId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 5),
  }) async {
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < timeout) {
      final statusResult = await getUploadStatus(uploadId);

      if (statusResult is Ok<PdfUploadModel>) {
        final upload = statusResult.value;
        if (upload.isCompleted || upload.isFailed || upload.isError) {
          return Result.ok(upload);
        }
      } else {
        return statusResult; // Return error immediately
      }

      // Wait before next check
      await Future.delayed(interval);
    }

    return Result.error(
      Exception('Quote processing timeout after ${timeout.inMinutes} minutes'),
    );
  }
}
