class ZonesCardModel {
  final int id;
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;

  ZonesCardModel({
    required this.id,
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
  });

  factory ZonesCardModel.fromJson(Map<String, dynamic> json) {
    return ZonesCardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      floorDimensionValue: json['floor_dimension_value'] ?? '',
      floorAreaValue: json['floor_area_value'] ?? '',
      areaPaintable: json['area_paintable'] ?? '',
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
    };
  }

  // Método para criar uma cópia com alterações
  ZonesCardModel copyWith({
    int? id,
    String? title,
    String? image,
    String? floorDimensionValue,
    String? floorAreaValue,
    String? areaPaintable,
  }) {
    return ZonesCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      floorDimensionValue: floorDimensionValue ?? this.floorDimensionValue,
      floorAreaValue: floorAreaValue ?? this.floorAreaValue,
      areaPaintable: areaPaintable ?? this.areaPaintable,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZonesCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class ZonesListResponse {
  final bool success;
  final List<ZonesCardModel> data;
  final String? message;

  ZonesListResponse({
    required this.success,
    required this.data,
    this.message,
  });

  factory ZonesListResponse.fromJson(Map<String, dynamic> json) {
    return ZonesListResponse(
      success: json['success'] ?? false,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => ZonesCardModel.fromJson(item))
              .toList() ??
          [],
      message: json['message'],
    );
  }
}

class ZonesSummaryModel {
  final String avgDimensions;
  final String totalArea;
  final String totalPaintable;

  ZonesSummaryModel({
    required this.avgDimensions,
    required this.totalArea,
    required this.totalPaintable,
  });

  factory ZonesSummaryModel.fromJson(Map<String, dynamic> json) {
    return ZonesSummaryModel(
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
  final ZonesCardModel? data;

  ZonesOperationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ZonesOperationResponse.fromJson(Map<String, dynamic> json) {
    return ZonesOperationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ZonesCardModel.fromJson(json['data']) : null,
    );
  }
}
