/// Zone type enum for the first zone
enum ZoneType {
  interior,
  exterior,
  both;

  String get name {
    switch (this) {
      case ZoneType.interior:
        return 'interior';
      case ZoneType.exterior:
        return 'exterior';
      case ZoneType.both:
        return 'both';
    }
  }

  static ZoneType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'interior':
        return ZoneType.interior;
      case 'exterior':
        return ZoneType.exterior;
      case 'both':
        return ZoneType.both;
      default:
        return ZoneType.interior;
    }
  }
}
