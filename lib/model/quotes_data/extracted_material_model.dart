import 'dart:developer';

class ExtractedMaterialModel {
  final int id;
  final int pdfUploadId;
  final int userId; // Campo obrigatório conforme documentação
  final String brand;
  final String description;
  final String type;
  final String unit;
  final double unitPrice;
  final String? finish;
  final String? qualityGrade;
  final String? category;
  final Map<String, dynamic>? specifications;
  final int lineNumber;
  final DateTime createdAt;
  final DateTime updatedAt;
  final PdfUploadInfo? pdfUpload;

  ExtractedMaterialModel({
    required this.id,
    required this.pdfUploadId,
    required this.userId, // Obrigatório
    required this.brand,
    required this.description,
    required this.type,
    required this.unit,
    required this.unitPrice,
    this.finish,
    this.qualityGrade,
    this.category,
    this.specifications,
    required this.lineNumber,
    required this.createdAt,
    required this.updatedAt,
    this.pdfUpload,
  });

  factory ExtractedMaterialModel.fromJson(Map<String, dynamic> json) {
    // Debug log to see the actual JSON data
    log('ExtractedMaterialModel.fromJson: Processing JSON: $json');

    // Validate required fields
    final requiredFields = [
      'id',
      'pdf_upload_id',
      'user_id',
      'brand',
      'description',
      'type',
      'unit',
      'unit_price',
      'line_number',
      'created_at',
      'updated_at',
    ];

    for (final field in requiredFields) {
      if (json[field] == null) {
        log(
          'ExtractedMaterialModel.fromJson: Missing required field: $field',
        );
        throw Exception('Missing required field: $field');
      }
    }

    // Debug specific fields that might cause type issues
    log(
      'ExtractedMaterialModel.fromJson: id type: ${json['id'].runtimeType}, value: ${json['id']}',
    );
    log(
      'ExtractedMaterialModel.fromJson: pdf_upload_id type: ${json['pdf_upload_id'].runtimeType}, value: ${json['pdf_upload_id']}',
    );
    log(
      'ExtractedMaterialModel.fromJson: user_id type: ${json['user_id'].runtimeType}, value: ${json['user_id']}',
    );
    log(
      'ExtractedMaterialModel.fromJson: unit_price type: ${json['unit_price'].runtimeType}, value: ${json['unit_price']}',
    );
    log(
      'ExtractedMaterialModel.fromJson: line_number type: ${json['line_number'].runtimeType}, value: ${json['line_number']}',
    );
    log(
      'ExtractedMaterialModel.fromJson: specifications type: ${json['specifications'].runtimeType}, value: ${json['specifications']}',
    );

    return ExtractedMaterialModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.parse(json['id'].toString()),
      pdfUploadId: json['pdf_upload_id'] is int
          ? json['pdf_upload_id'] as int
          : int.parse(json['pdf_upload_id'].toString()),
      userId: json['user_id'] is int
          ? json['user_id'] as int
          : int.parse(json['user_id'].toString()),
      brand: json['brand'] as String,
      description: json['description'] as String,
      type: json['type'] as String,
      unit: json['unit'] as String,
      unitPrice: json['unit_price'] is num
          ? (json['unit_price'] as num).toDouble()
          : double.parse(json['unit_price'].toString()),
      finish: json['finish'] as String?,
      qualityGrade: json['quality_grade'] as String?,
      category: json['category'] as String?,
      specifications: json['specifications'] is Map<String, dynamic>
          ? json['specifications'] as Map<String, dynamic>
          : json['specifications'] is List
          ? null
          : json['specifications'] as Map<String, dynamic>?,
      lineNumber: json['line_number'] is int
          ? json['line_number'] as int
          : int.parse(json['line_number'].toString()),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      pdfUpload: json['pdf_upload'] != null
          ? PdfUploadInfo.fromJson(json['pdf_upload'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdf_upload_id': pdfUploadId,
      'user_id': userId,
      'brand': brand,
      'description': description,
      'type': type,
      'unit': unit,
      'unit_price': unitPrice,
      'finish': finish,
      'quality_grade': qualityGrade,
      'category': category,
      'specifications': specifications,
      'line_number': lineNumber,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'pdf_upload': pdfUpload?.toJson(),
    };
  }

  ExtractedMaterialModel copyWith({
    int? id,
    int? pdfUploadId,
    int? userId,
    String? brand,
    String? description,
    String? type,
    String? unit,
    double? unitPrice,
    String? finish,
    String? qualityGrade,
    String? category,
    Map<String, dynamic>? specifications,
    int? lineNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
    PdfUploadInfo? pdfUpload,
  }) {
    return ExtractedMaterialModel(
      id: id ?? this.id,
      pdfUploadId: pdfUploadId ?? this.pdfUploadId,
      userId: userId ?? this.userId,
      brand: brand ?? this.brand,
      description: description ?? this.description,
      type: type ?? this.type,
      unit: unit ?? this.unit,
      unitPrice: unitPrice ?? this.unitPrice,
      finish: finish ?? this.finish,
      qualityGrade: qualityGrade ?? this.qualityGrade,
      category: category ?? this.category,
      specifications: specifications ?? this.specifications,
      lineNumber: lineNumber ?? this.lineNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pdfUpload: pdfUpload ?? this.pdfUpload,
    );
  }

  String get formattedPrice => '\$${unitPrice.toStringAsFixed(2)}';

  String get displayName => '$brand - $description';

  String get fullDescription {
    final parts = <String>[description];
    if (finish != null) parts.add(finish!);
    if (qualityGrade != null) parts.add(qualityGrade!);
    return parts.join(' - ');
  }
}

class PdfUploadInfo {
  final int id;
  final String originalName;
  final String? displayName;
  final DateTime createdAt;

  PdfUploadInfo({
    required this.id,
    required this.originalName,
    this.displayName,
    required this.createdAt,
  });

  factory PdfUploadInfo.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final requiredFields = ['id', 'original_name', 'created_at'];

    for (final field in requiredFields) {
      if (json[field] == null) {
        throw Exception('Missing required field: $field');
      }
    }

    return PdfUploadInfo(
      id: json['id'] as int,
      originalName: json['original_name'] as String,
      displayName: json['display_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_name': originalName,
      'display_name': displayName,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

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
    log('ExtractedMaterialListResponse.fromJson: Processing response JSON');

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

    // Debug filters_applied field
    log(
      'ExtractedMaterialListResponse.fromJson: filters_applied type: ${data['filters_applied'].runtimeType}, value: ${data['filters_applied']}',
    );

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

class MaterialFilters {
  final String? brand;
  final String? ambient;
  final String? finish;
  final List<String>? quality;
  final String? search;
  final String sortBy;
  final String sortOrder;
  final int page;

  MaterialFilters({
    this.brand,
    this.ambient,
    this.finish,
    this.quality,
    this.search,
    this.sortBy = 'created_at',
    this.sortOrder = 'desc',
    this.page = 1,
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{};

    if (brand != null && brand!.isNotEmpty) params['brand'] = brand;
    if (ambient != null && ambient!.isNotEmpty) params['ambient'] = ambient;
    if (finish != null && finish!.isNotEmpty) params['finish'] = finish;
    if (search != null && search!.isNotEmpty) params['search'] = search;

    // Qualidade pode ser múltipla (array) - formato correto da API
    if (quality != null && quality!.isNotEmpty) {
      if (quality!.length == 1) {
        params['quality'] = quality!.first;
      } else {
        for (int i = 0; i < quality!.length; i++) {
          params['quality[]'] = quality![i];
        }
      }
    }

    params['sort_by'] = sortBy;
    params['sort_order'] = sortOrder;
    params['page'] = page.toString();

    return params;
  }

  MaterialFilters copyWith({
    String? brand,
    String? ambient,
    String? finish,
    List<String>? quality,
    String? search,
    String? sortBy,
    String? sortOrder,
    int? page,
  }) {
    return MaterialFilters(
      brand: brand ?? this.brand,
      ambient: ambient ?? this.ambient,
      finish: finish ?? this.finish,
      quality: quality ?? this.quality,
      search: search ?? this.search,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      page: page ?? this.page,
    );
  }

  bool get isEmpty =>
      brand == null &&
      ambient == null &&
      finish == null &&
      (quality == null || quality!.isEmpty) &&
      (search == null || search!.isEmpty);
}

class MaterialFiltersOptions {
  final List<String> brands;
  final List<String> ambients;
  final List<String> finishes;
  final List<String> qualities;

  MaterialFiltersOptions({
    required this.brands,
    required this.ambients,
    required this.finishes,
    required this.qualities,
  });

  factory MaterialFiltersOptions.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    if (json['success'] == null) {
      throw Exception('Missing required field: success');
    }

    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Missing required field: data');
    }

    final filters = data['filters'] as Map<String, dynamic>?;
    if (filters == null) {
      throw Exception('Missing required field: data.filters');
    }

    return MaterialFiltersOptions(
      brands: List<String>.from(filters['brands'] as List? ?? []),
      ambients: List<String>.from(filters['ambients'] as List? ?? []),
      finishes: List<String>.from(filters['finishes'] as List? ?? []),
      qualities: List<String>.from(filters['qualities'] as List? ?? []),
    );
  }
}

class PaginationInfo {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;

  PaginationInfo({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    // Validate required fields
    final requiredFields = ['total', 'per_page', 'current_page', 'last_page'];

    for (final field in requiredFields) {
      if (json[field] == null) {
        throw Exception('Missing required field: $field');
      }
    }

    return PaginationInfo(
      total: json['total'] as int,
      perPage: json['per_page'] as int,
      currentPage: json['current_page'] as int,
      lastPage: json['last_page'] as int,
      from: json['from'] as int?,
      to: json['to'] as int?,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
  bool get hasPreviousPage => currentPage > 1;
}
