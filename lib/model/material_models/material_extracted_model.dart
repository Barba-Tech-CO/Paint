class MaterialExtracted {
  final int id;
  final int pdfUploadId;
  final int? userId;
  final String name;
  final String? description;
  final double? quantity;
  final String? unit;
  final double? unitPrice;
  final double? totalPrice;
  final String? category;
  final String? brand;
  final String? code;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  MaterialExtracted({
    required this.id,
    required this.pdfUploadId,
    this.userId,
    required this.name,
    this.description,
    this.quantity,
    this.unit,
    this.unitPrice,
    this.totalPrice,
    this.category,
    this.brand,
    this.code,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MaterialExtracted.fromJson(Map<String, dynamic> json) {
    return MaterialExtracted(
      id: json['id'],
      pdfUploadId: json['pdf_upload_id'],
      userId: json['user_id'],
      name: json['name'],
      description: json['description'],
      quantity: json['quantity']?.toDouble(),
      unit: json['unit'],
      unitPrice: json['unit_price']?.toDouble(),
      totalPrice: json['total_price']?.toDouble(),
      category: json['category'],
      brand: json['brand'],
      code: json['code'],
      metadata: json['metadata'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pdf_upload_id': pdfUploadId,
      'user_id': userId,
      'name': name,
      'description': description,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'category': category,
      'brand': brand,
      'code': code,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class MaterialExtractedResponse {
  final bool success;
  final MaterialExtractedData data;

  MaterialExtractedResponse({
    required this.success,
    required this.data,
  });

  factory MaterialExtractedResponse.fromJson(Map<String, dynamic> json) {
    return MaterialExtractedResponse(
      success: json['success'],
      data: MaterialExtractedData.fromJson(json['data']),
    );
  }
}

class MaterialExtractedData {
  final List<MaterialExtracted> materials;
  final MaterialPagination pagination;
  final MaterialFiltersApplied filtersApplied;

  MaterialExtractedData({
    required this.materials,
    required this.pagination,
    required this.filtersApplied,
  });

  factory MaterialExtractedData.fromJson(Map<String, dynamic> json) {
    return MaterialExtractedData(
      materials: (json['materials'] as List)
          .map((material) => MaterialExtracted.fromJson(material))
          .toList(),
      pagination: MaterialPagination.fromJson(json['pagination']),
      filtersApplied: MaterialFiltersApplied.fromJson(json['filters_applied']),
    );
  }
}

class MaterialPagination {
  final int total;
  final int perPage;
  final int currentPage;
  final int lastPage;
  final int? from;
  final int? to;

  MaterialPagination({
    required this.total,
    required this.perPage,
    required this.currentPage,
    required this.lastPage,
    this.from,
    this.to,
  });

  factory MaterialPagination.fromJson(Map<String, dynamic> json) {
    return MaterialPagination(
      total: json['total'],
      perPage: json['per_page'],
      currentPage: json['current_page'],
      lastPage: json['last_page'],
      from: json['from'],
      to: json['to'],
    );
  }
}

class MaterialFiltersApplied {
  final String? brand;
  final String? ambient;
  final String? finish;
  final List<String>? quality;
  final String? search;

  MaterialFiltersApplied({
    this.brand,
    this.ambient,
    this.finish,
    this.quality,
    this.search,
  });

  factory MaterialFiltersApplied.fromJson(Map<String, dynamic> json) {
    return MaterialFiltersApplied(
      brand: json['brand'],
      ambient: json['ambient'],
      finish: json['finish'],
      quality: json['quality'] != null
          ? List<String>.from(json['quality'])
          : null,
      search: json['search'],
    );
  }
}
