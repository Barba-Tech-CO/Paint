import 'extracted_material_model.dart';
import 'pagination_info.dart';

class ExtractedMaterialListResponse {
  final bool success;
  final List<ExtractedMaterialModel> materials;
  final PaginationInfo pagination;
  final Map<String, dynamic>? filtersApplied;

  ExtractedMaterialListResponse({
    required this.success,
    required this.materials,
    required this.pagination,
    this.filtersApplied,
  });

  factory ExtractedMaterialListResponse.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['success'] == null) {
      throw Exception('Missing required field: success');
    }

    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Missing required field: data');
    }

    if (data['materials'] == null) {
      throw Exception('Missing required field: data.materials');
    }

    if (data['pagination'] == null) {
      throw Exception('Missing required field: data.pagination');
    }

    return ExtractedMaterialListResponse(
      success: json['success'] as bool,
      materials: (data['materials'] as List)
          .map(
            (item) =>
                ExtractedMaterialModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      pagination: PaginationInfo.fromJson(
        data['pagination'] as Map<String, dynamic>,
      ),
      filtersApplied: data['filters_applied'] is Map<String, dynamic>
          ? data['filters_applied'] as Map<String, dynamic>
          : data['filters_applied'] is List
          ? null
          : data['filters_applied'] as Map<String, dynamic>?,
    );
  }
}
