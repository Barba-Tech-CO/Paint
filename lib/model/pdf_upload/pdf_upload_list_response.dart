import 'dart:developer';
import 'pdf_upload_model.dart';
import 'pagination_info.dart';

class PdfUploadListResponse {
  final bool success;
  final List<PdfUploadModel> uploads;
  final PaginationInfo pagination;

  PdfUploadListResponse({
    required this.success,
    required this.uploads,
    required this.pagination,
  });

  factory PdfUploadListResponse.fromJson(Map<String, dynamic> json) {
    log('DEBUG: PdfUploadListResponse.fromJson - json: $json');

    final data = json['data'] as Map<String, dynamic>?;
    log('DEBUG: PdfUploadListResponse.fromJson - data: $data');

    if (data == null) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - data is null, returning empty response',
      );
      return PdfUploadListResponse(
        success: json['success'] as bool? ?? false,
        uploads: [],
        pagination: PaginationInfo(
          total: 0,
          perPage: 10,
          currentPage: 1,
          lastPage: 1,
        ),
      );
    }

    final uploadsData = data['uploads'];
    log(
      'DEBUG: PdfUploadListResponse.fromJson - uploadsData: $uploadsData (type: ${uploadsData.runtimeType})',
    );

    if (uploadsData == null) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData is null, returning empty response',
      );
      return PdfUploadListResponse(
        success: json['success'] as bool? ?? false,
        uploads: [],
        pagination: PaginationInfo(
          total: 0,
          perPage: 10,
          currentPage: 1,
          lastPage: 1,
        ),
      );
    }

    // Handle the case where uploadsData is a Map (with pagination info)
    if (uploadsData is Map<String, dynamic>) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData is a Map, extracting data and pagination',
      );

      final uploadsList = uploadsData['data'] as List<dynamic>? ?? [];
      final currentPage = uploadsData['current_page'] as int? ?? 1;
      final perPage = uploadsData['per_page'] as int? ?? 10;
      final total = uploadsData['total'] as int? ?? 0;
      final lastPage = uploadsData['last_page'] as int? ?? 1;

      final pagination = PaginationInfo(
        total: total,
        perPage: perPage,
        currentPage: currentPage,
        lastPage: lastPage,
      );

      final uploads = uploadsList
          .map(
            (item) => PdfUploadModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return PdfUploadListResponse(
        success: json['success'] as bool? ?? false,
        uploads: uploads,
        pagination: pagination,
      );
    }

    // Handle the case where uploadsData is a List (legacy format)
    if (uploadsData is List) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData is a List, using legacy format',
      );

      final paginationData = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationData != null
          ? PaginationInfo.fromJson(paginationData)
          : PaginationInfo(
              total: uploadsData.length,
              perPage: uploadsData.length,
              currentPage: 1,
              lastPage: 1,
            );

      return PdfUploadListResponse(
        success: json['success'] as bool? ?? false,
        uploads: uploadsData
            .map(
              (item) => PdfUploadModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        pagination: pagination,
      );
    }

    // Fallback for unexpected data types
    log(
      'DEBUG: PdfUploadListResponse.fromJson - uploadsData is unexpected type: ${uploadsData.runtimeType}, returning empty response',
    );

    // Try to extract any useful information from the unexpected structure
    if (uploadsData is Map<String, dynamic>) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData keys: ${uploadsData.keys.toList()}',
      );
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData values: ${uploadsData.values.toList()}',
      );
    }

    return PdfUploadListResponse(
      success: json['success'] as bool? ?? false,
      uploads: [],
      pagination: PaginationInfo(
        total: 0,
        perPage: 10,
        currentPage: 1,
        lastPage: 1,
      ),
    );
  }
}
