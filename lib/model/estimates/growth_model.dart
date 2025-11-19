class GrowthModel {
  final double revenuePercentage;
  final double estimatesPercentage;

  const GrowthModel({
    required this.revenuePercentage,
    required this.estimatesPercentage,
  });

  factory GrowthModel.fromJson(Map<String, dynamic> json) {
    return GrowthModel(
      revenuePercentage: (json['revenue_percentage'] ?? 0.0).toDouble(),
      estimatesPercentage: (json['estimates_percentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'revenue_percentage': revenuePercentage,
      'estimates_percentage': estimatesPercentage,
    };
  }
}
