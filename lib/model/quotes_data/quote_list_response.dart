import 'pagination_info.dart';
import 'quote_model.dart';

class QuoteListResponse {
  final bool success;
  final List<QuoteModel> quotes;
  final PaginationInfo pagination;

  QuoteListResponse({
    required this.success,
    required this.quotes,
    required this.pagination,
  });

  factory QuoteListResponse.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['success'] == null) {
      throw Exception('Missing required field: success');
    }

    final data = json['data'] as Map<String, dynamic>?;

    if (data == null) {
      return QuoteListResponse(
        success: json['success'] as bool,
        quotes: [],
        pagination: PaginationInfo(
          total: 0,
          perPage: 10,
          currentPage: 1,
          lastPage: 1,
        ),
      );
    }

    final uploadsData = data['uploads'];

    if (uploadsData == null) {
      return QuoteListResponse(
        success: json['success'] as bool,
        quotes: [],
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
            (item) => QuoteModel.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return QuoteListResponse(
        success: json['success'] as bool? ?? false,
        quotes: uploads,
        pagination: pagination,
      );
    }

    // Handle the case where uploadsData is a List (legacy format)
    if (uploadsData is List) {
      final paginationData = data['pagination'] as Map<String, dynamic>?;
      final pagination = paginationData != null
          ? PaginationInfo.fromJson(paginationData)
          : PaginationInfo(
              total: uploadsData.length,
              perPage: uploadsData.length,
              currentPage: 1,
              lastPage: 1,
            );

      return QuoteListResponse(
        success: json['success'] as bool,
        quotes: uploadsData
            .map(
              (item) => QuoteModel.fromJson(item as Map<String, dynamic>),
            )
            .toList(),
        pagination: pagination,
      );
    }

    return QuoteListResponse(
      success: json['success'] as bool,
      quotes: [],
      pagination: PaginationInfo(
        total: 0,
        perPage: 10,
        currentPage: 1,
        lastPage: 1,
      ),
    );
  }
}
