import 'estimate_status.dart';
import 'project_type.dart';
import 'estimate_element.dart';

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
