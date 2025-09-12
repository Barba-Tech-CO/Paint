enum ProjectType {
  residential,
  commercial,
  industrial,
  other;

  String get displayName {
    switch (this) {
      case ProjectType.residential:
        return 'Residential';
      case ProjectType.commercial:
        return 'Commercial';
      case ProjectType.industrial:
        return 'Industrial';
      case ProjectType.other:
        return 'Other';
    }
  }
}
