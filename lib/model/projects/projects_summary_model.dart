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
