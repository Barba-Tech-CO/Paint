class ProjectModel {
  final int id;
  final String projectName;
  final String personName;
  final int zonesCount;
  final String createdDate;
  final String image;

  ProjectModel({
    required this.id,
    required this.projectName,
    required this.personName,
    required this.zonesCount,
    required this.createdDate,
    required this.image,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'] ?? 0,
      projectName: json['project_name'] ?? '',
      personName: json['person_name'] ?? '',
      zonesCount: json['zones_count'] ?? 0,
      createdDate: json['created_date'] ?? '',
      image: json['image'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_name': projectName,
      'person_name': personName,
      'zones_count': zonesCount,
      'created_date': createdDate,
      'image': image,
    };
  }

  // Método para criar uma cópia com alterações
  ProjectModel copyWith({
    int? id,
    String? projectName,
    String? personName,
    int? zonesCount,
    String? createdDate,
    String? image,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      projectName: projectName ?? this.projectName,
      personName: personName ?? this.personName,
      zonesCount: zonesCount ?? this.zonesCount,
      createdDate: createdDate ?? this.createdDate,
      image: image ?? this.image,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
