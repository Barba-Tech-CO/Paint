enum EstimateStatus {
  draft,
  inProgress,
  completed,
  sent,
  cancelled;

  String get displayName {
    switch (this) {
      case EstimateStatus.draft:
        return 'Rascunho';
      case EstimateStatus.inProgress:
        return 'Em Andamento';
      case EstimateStatus.completed:
        return 'Concluído';
      case EstimateStatus.sent:
        return 'Enviado';
      case EstimateStatus.cancelled:
        return 'Cancelado';
    }
  }
}

enum ProjectType {
  residential,
  commercial,
  industrial,
  other;

  String get displayName {
    switch (this) {
      case ProjectType.residential:
        return 'Residencial';
      case ProjectType.commercial:
        return 'Comercial';
      case ProjectType.industrial:
        return 'Industrial';
      case ProjectType.other:
        return 'Outro';
    }
  }
}

class EstimateModel {
  final String? id;
  final String? projectName;
  final String? clientName;
  final ProjectType? projectType;
  final EstimateStatus status;
  final double? totalArea;
  final double? totalCost;
  final List<String>? photos;
  final List<EstimateElement>? elements;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? completedAt;

  EstimateModel({
    this.id,
    this.projectName,
    this.clientName,
    this.projectType,
    required this.status,
    this.totalArea,
    this.totalCost,
    this.photos,
    this.elements,
    this.createdAt,
    this.updatedAt,
    this.completedAt,
  });

  factory EstimateModel.fromJson(Map<String, dynamic> json) {
    return EstimateModel(
      id: json['id'],
      projectName: json['project_name'],
      clientName: json['client_name'],
      projectType: json['project_type'] != null
          ? ProjectType.values.firstWhere(
              (e) => e.name == json['project_type'],
              orElse: () => ProjectType.other,
            )
          : null,
      status: EstimateStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => EstimateStatus.draft,
      ),
      totalArea: json['total_area']?.toDouble(),
      totalCost: json['total_cost']?.toDouble(),
      photos: json['photos'] != null ? List<String>.from(json['photos']) : null,
      elements: json['elements'] != null
          ? (json['elements'] as List<dynamic>)
                .map((element) => EstimateElement.fromJson(element))
                .toList()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'client_name': clientName,
      'project_type': projectType?.name,
      'status': status.name,
      'total_area': totalArea,
      'total_cost': totalCost,
      'photos': photos,
      'elements': elements?.map((e) => e.toJson()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  EstimateModel copyWith({
    String? id,
    String? projectName,
    String? clientName,
    ProjectType? projectType,
    EstimateStatus? status,
    double? totalArea,
    double? totalCost,
    List<String>? photos,
    List<EstimateElement>? elements,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return EstimateModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      clientName: clientName ?? this.clientName,
      projectType: projectType ?? this.projectType,
      status: status ?? this.status,
      totalArea: totalArea ?? this.totalArea,
      totalCost: totalCost ?? this.totalCost,
      photos: photos ?? this.photos,
      elements: elements ?? this.elements,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

class EstimateElement {
  final String? brandKey;
  final String? colorKey;
  final String? usage;
  final String? sizeKey;
  final int? quantity;
  final double? unitPrice;
  final double? totalPrice;

  EstimateElement({
    this.brandKey,
    this.colorKey,
    this.usage,
    this.sizeKey,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  factory EstimateElement.fromJson(Map<String, dynamic> json) {
    return EstimateElement(
      brandKey: json['brand_key'],
      colorKey: json['color_key'],
      usage: json['usage'],
      sizeKey: json['size_key'],
      quantity: json['quantity'],
      unitPrice: json['unit_price']?.toDouble(),
      totalPrice: json['total_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_key': brandKey,
      'color_key': colorKey,
      'usage': usage,
      'size_key': sizeKey,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}

class EstimateListResponse {
  final List<EstimateModel> estimates;
  final int? total;
  final int? limit;
  final int? offset;

  EstimateListResponse({
    required this.estimates,
    this.total,
    this.limit,
    this.offset,
  });

  factory EstimateListResponse.fromJson(Map<String, dynamic> json) {
    final estimatesList = json['estimates'] as List<dynamic>? ?? [];
    return EstimateListResponse(
      estimates: estimatesList
          .map((estimate) => EstimateModel.fromJson(estimate))
          .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}

class EstimateResponse {
  final bool success;
  final String? message;
  final EstimateModel? data;

  EstimateResponse({
    required this.success,
    this.message,
    this.data,
  });

  factory EstimateResponse.fromJson(Map<String, dynamic> json) {
    return EstimateResponse(
      success: json['success'] ?? false,
      message: json['message'],
      data: json['data'] != null ? EstimateModel.fromJson(json['data']) : null,
    );
  }
}

class DashboardData {
  final int totalEstimates;
  final int completedEstimates;
  final int pendingEstimates;
  final double totalRevenue;
  final List<EstimateModel> recentEstimates;

  DashboardData({
    required this.totalEstimates,
    required this.completedEstimates,
    required this.pendingEstimates,
    required this.totalRevenue,
    required this.recentEstimates,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final recentEstimatesList =
        json['recent_estimates'] as List<dynamic>? ?? [];
    return DashboardData(
      totalEstimates: json['total_estimates'] ?? 0,
      completedEstimates: json['completed_estimates'] ?? 0,
      pendingEstimates: json['pending_estimates'] ?? 0,
      totalRevenue: json['total_revenue']?.toDouble() ?? 0.0,
      recentEstimates: recentEstimatesList
          .map((estimate) => EstimateModel.fromJson(estimate))
          .toList(),
    );
  }
}

class DashboardResponse {
  final bool success;
  final DashboardData? data;

  DashboardResponse({
    required this.success,
    this.data,
  });

  factory DashboardResponse.fromJson(Map<String, dynamic> json) {
    return DashboardResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? DashboardData.fromJson(json['data']) : null,
    );
  }
}
