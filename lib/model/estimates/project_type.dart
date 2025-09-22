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
}
