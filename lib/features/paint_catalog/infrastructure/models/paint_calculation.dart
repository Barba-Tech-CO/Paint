class PaintCalculation {
  final int gallonsNeeded;
  final double totalCost;
  final double area;
  final String brandKey;
  final String colorKey;
  final String usage;

  PaintCalculation({
    required this.gallonsNeeded,
    required this.totalCost,
    required this.area,
    required this.brandKey,
    required this.colorKey,
    required this.usage,
  });

  factory PaintCalculation.fromJson(Map<String, dynamic> json) {
    return PaintCalculation(
      gallonsNeeded: json['gallons_needed'] ?? 0,
      totalCost: json['total_cost']?.toDouble() ?? 0.0,
      area: json['area']?.toDouble() ?? 0.0,
      brandKey: json['brand_key'] ?? '',
      colorKey: json['color_key'] ?? '',
      usage: json['usage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallons_needed': gallonsNeeded,
      'total_cost': totalCost,
      'area': area,
      'brand_key': brandKey,
      'color_key': colorKey,
      'usage': usage,
    };
  }
}
