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

    if (uploadsData is! List) {
      log(
        'DEBUG: PdfUploadListResponse.fromJson - uploadsData is not a List, it\'s: ${uploadsData.runtimeType}',
      );
      // Se não for uma lista, retornar resposta vazia
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
}
