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
