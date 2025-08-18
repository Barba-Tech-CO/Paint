enum ProjectType {
  interior,
  exterior,
  both;

  String get displayName {
    switch (this) {
      case ProjectType.interior:
        return 'Interior';
      case ProjectType.exterior:
        return 'Exterior';
      case ProjectType.both:
        return 'Both';
    }
  }

  static ProjectType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'interior':
        return ProjectType.interior;
      case 'exterior':
        return ProjectType.exterior;
      case 'both':
        return ProjectType.both;
      default:
        return ProjectType.interior;
    }
  }
}

class ProjectForm {
  final String clientName;
  final String projectName;
  final ProjectType projectType;
  final String additionalNotes;

  const ProjectForm({
    required this.clientName,
    required this.projectName,
    required this.projectType,
    this.additionalNotes = '',
  });

  bool get isValid {
    return clientName.trim().isNotEmpty && projectName.trim().isNotEmpty;
  }

  ProjectForm copyWith({
    String? clientName,
    String? projectName,
    ProjectType? projectType,
    String? additionalNotes,
  }) {
    return ProjectForm(
      clientName: clientName ?? this.clientName,
      projectName: projectName ?? this.projectName,
      projectType: projectType ?? this.projectType,
      additionalNotes: additionalNotes ?? this.additionalNotes,
    );
  }
}