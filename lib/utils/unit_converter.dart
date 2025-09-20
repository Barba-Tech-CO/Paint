/// Utility class for unit conversions to ensure imperial units are always used
/// Based on the flutter_roomplan package unit conversion system
class UnitConverter {
  /// Conversion factor from meters to feet
  static const double metersToFeet = 3.28084;

  /// Conversion factor from feet to meters
  static const double feetToMeters = 0.3048;

  /// Conversion factor from square meters to square feet
  static const double sqMetersToSqFeet = 10.7639;

  /// Conversion factor from square feet to square meters
  static const double sqFeetToSqMeters = 0.092903;

  /// Converts meters to feet
  static double metersToFeetConversion(double meters) {
    return meters * metersToFeet;
  }

  /// Converts feet to meters
  static double feetToMetersConversion(double feet) {
    return feet * feetToMeters;
  }

  /// Converts square meters to square feet
  static double sqMetersToSqFeetConversion(double sqMeters) {
    return sqMeters * sqMetersToSqFeet;
  }

  /// Converts square feet to square meters
  static double sqFeetToSqMetersConversion(double sqFeet) {
    return sqFeet * sqFeetToSqMeters;
  }

  /// Formats a length value in feet with appropriate precision
  static String formatLengthInFeet(double meters, {int decimals = 0}) {
    final feet = metersToFeetConversion(meters);
    return '${feet.toStringAsFixed(decimals)} ft';
  }

  /// Formats an area value in square feet with appropriate precision
  static String formatAreaInSqFeet(double sqMeters, {int decimals = 0}) {
    final sqFeet = sqMetersToSqFeetConversion(sqMeters);
    return '${sqFeet.toStringAsFixed(decimals)} sq ft';
  }

  /// Formats an area value showing both square meters and square feet
  static String formatAreaDualUnits(double sqMeters, {int decimals = 0}) {
    final sqFeet = sqMetersToSqFeetConversion(sqMeters);
    return '${sqMeters.toStringAsFixed(decimals)} sq m / ${sqFeet.toStringAsFixed(decimals)} sq ft';
  }

  /// Formats dimensions showing both meters and feet
  static String formatDimensionsDualUnits(
    double widthMeters,
    double lengthMeters, {
    int decimals = 0,
  }) {
    final widthFeet = metersToFeetConversion(widthMeters);
    final lengthFeet = metersToFeetConversion(lengthMeters);
    return '${widthMeters.toStringAsFixed(decimals)} x ${lengthMeters.toStringAsFixed(decimals)} m / ${widthFeet.toStringAsFixed(decimals)} x ${lengthFeet.toStringAsFixed(decimals)} ft';
  }

  /// Formats dimensions in feet only
  static String formatDimensionsInFeet(
    double widthMeters,
    double lengthMeters, {
    int decimals = 0,
  }) {
    final widthFeet = metersToFeetConversion(widthMeters);
    final lengthFeet = metersToFeetConversion(lengthMeters);
    return '${widthFeet.toStringAsFixed(decimals)} x ${lengthFeet.toStringAsFixed(decimals)} ft';
  }

  /// Formats area in square feet only
  static String formatAreaInSqFeetOnly(double sqMeters, {int decimals = 0}) {
    final sqFeet = sqMetersToSqFeetConversion(sqMeters);
    return '${sqFeet.toStringAsFixed(decimals)} sq ft';
  }
}
