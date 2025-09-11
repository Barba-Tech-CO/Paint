import '../estimate_model.dart';

class DashboardData {
  final int totalEstimates;
  final int completedEstimates;
  final int pendingEstimates;
  final double totalRevenue;
  final List<EstimateModel> recentEstimates;

  DashboardData({
    required this.totalEstimates,
    required this.completedEstimates,
    required this.pendingEstimates,
    required this.totalRevenue,
    required this.recentEstimates,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final recentEstimatesList =
        json['recent_estimates'] as List<dynamic>? ?? [];
    return DashboardData(
      totalEstimates: json['total_estimates'] ?? 0,
      completedEstimates: json['completed_estimates'] ?? 0,
      pendingEstimates: json['pending_estimates'] ?? 0,
      totalRevenue: json['total_revenue']?.toDouble() ?? 0.0,
      recentEstimates: recentEstimatesList
          .map((estimate) => EstimateModel.fromJson(estimate))
          .toList(),
    );
  }
}
