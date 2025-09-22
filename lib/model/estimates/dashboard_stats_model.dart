class DashboardStatsModel {
  final int totalEstimates;
  final int completed;
  final int sent;
  final int pending;

  const DashboardStatsModel({
    required this.totalEstimates,
    required this.completed,
    required this.sent,
    required this.pending,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      totalEstimates: json['total_estimates'] ?? 0,
      completed: json['completed'] ?? 0,
      sent: json['sent'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_estimates': totalEstimates,
      'completed': completed,
      'sent': sent,
      'pending': pending,
    };
  }
}
