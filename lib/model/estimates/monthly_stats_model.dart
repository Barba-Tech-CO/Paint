class MonthlyStatsModel {
  final double totalRevenue;
  final double completedRevenue;
  final double sentRevenue;
  final double averageEstimateValue;
  final int totalEstimates;
  final String monthYear;

  const MonthlyStatsModel({
    required this.totalRevenue,
    required this.completedRevenue,
    required this.sentRevenue,
    required this.averageEstimateValue,
    required this.totalEstimates,
    required this.monthYear,
  });

  factory MonthlyStatsModel.fromJson(Map<String, dynamic> json) {
    return MonthlyStatsModel(
      totalRevenue: (json['total_revenue'] ?? 0.0).toDouble(),
      completedRevenue: (json['completed_revenue'] ?? 0.0).toDouble(),
      sentRevenue: (json['sent_revenue'] ?? 0.0).toDouble(),
      averageEstimateValue: (json['average_estimate_value'] ?? 0.0).toDouble(),
      totalEstimates: json['total_estimates'] ?? 0,
      monthYear: json['month_year'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_revenue': totalRevenue,
      'completed_revenue': completedRevenue,
      'sent_revenue': sentRevenue,
      'average_estimate_value': averageEstimateValue,
      'total_estimates': totalEstimates,
      'month_year': monthYear,
    };
  }
}
