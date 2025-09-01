class ProjectCardModel {
  final int id;
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;
  final String? ceilingArea;
  final String? trimLength;

  ProjectCardModel({
    required this.id,
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
    this.ceilingArea,
    this.trimLength,
  });

  factory ProjectCardModel.fromJson(Map<String, dynamic> json) {
    return ProjectCardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      floorDimensionValue: json['floor_dimension_value'] ?? '',
      floorAreaValue: json['floor_area_value'] ?? '',
      areaPaintable: json['area_paintable'] ?? '',
      ceilingArea: json['ceiling_area'],
      trimLength: json['trim_length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'floor_dimension_value': floorDimensionValue,
      'floor_area_value': floorAreaValue,
      'area_paintable': areaPaintable,
      'ceiling_area': ceilingArea,
      'trim_length': trimLength,
    };
  }

  // Método para criar uma cópia com alterações
  ProjectCardModel copyWith({
    int? id,
    String? title,
    String? image,
    String? floorDimensionValue,
    String? floorAreaValue,
    String? areaPaintable,
    String? ceilingArea,
    String? trimLength,
  }) {
    return ProjectCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      floorDimensionValue: floorDimensionValue ?? this.floorDimensionValue,
      floorAreaValue: floorAreaValue ?? this.floorAreaValue,
      areaPaintable: areaPaintable ?? this.areaPaintable,
      ceilingArea: ceilingArea ?? this.ceilingArea,
      trimLength: trimLength ?? this.trimLength,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ProjectListResponse {
  final bool success;
  final List<ProjectCardModel> data;
  final String? message;

  ProjectListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ProjectListResponse.fromJson(Map<String, dynamic> json) {
    return ProjectListResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ProjectCardModel.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

class ProjectsSummaryModel {
  final String avgDimensions;
  final String totalArea;
  final String totalPaintable;

  ProjectsSummaryModel({
    required this.avgDimensions,
    required this.totalArea,
    required this.totalPaintable,
  });

  factory ProjectsSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProjectsSummaryModel(
      avgDimensions: json['avg_dimensions'] ?? '',
      totalArea: json['total_area'] ?? '',
      totalPaintable: json['total_paintable'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avg_dimensions': avgDimensions,
      'total_area': totalArea,
      'total_paintable': totalPaintable,
    };
  }
}

class ZonesOperationResponse {
  final bool success;
  final String message;
  final ProjectCardModel? data;

  ZonesOperationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ZonesOperationResponse.fromJson(Map<String, dynamic> json) {
    return ZonesOperationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProjectCardModel.fromJson(json['data'])
          : null,
    );
  }
}
