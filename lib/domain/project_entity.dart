class ProjectEntity {
  final String projectName;
  final String contactId;
  final String additionalNotes;
  final String projectType;
  final String zoneType;

  const ProjectEntity({
    required this.projectName,
    required this.contactId,
    required this.additionalNotes,
    required this.projectType,
    required this.zoneType,
  });

  factory ProjectEntity.fromMap(Map<String, dynamic> map) {
    return ProjectEntity(
      projectName: map['projectName'] ?? '',
      contactId: map['clientId'] ?? '',
      additionalNotes: map['additionalNotes'] ?? '',
      projectType: map['projectType'] ?? '',
      zoneType: _getZoneTypeFromProjectType(map['projectType'] ?? ''),
    );
  }

  static String _getZoneTypeFromProjectType(String projectType) {
    switch (projectType.toLowerCase()) {
      case 'interior':
        return 'interior';
      case 'exterior':
        return 'exterior';
      case 'both':
        return 'both';
      default:
        return 'interior';
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'projectName': projectName,
      'clientId': contactId,
      'additionalNotes': additionalNotes,
      'projectType': projectType,
      'zoneType': zoneType,
    };
  }

  ProjectEntity copyWith({
    String? projectName,
    String? contactId,
    String? additionalNotes,
    String? projectType,
    String? zoneType,
  }) {
    return ProjectEntity(
      projectName: projectName ?? this.projectName,
      contactId: contactId ?? this.contactId,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      projectType: projectType ?? this.projectType,
      zoneType: zoneType ?? this.zoneType,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectEntity &&
        other.projectName == projectName &&
        other.contactId == contactId &&
        other.additionalNotes == additionalNotes &&
        other.projectType == projectType &&
        other.zoneType == zoneType;
  }

  @override
  int get hashCode {
    return projectName.hashCode ^
        contactId.hashCode ^
        additionalNotes.hashCode ^
        projectType.hashCode ^
        zoneType.hashCode;
  }
}
