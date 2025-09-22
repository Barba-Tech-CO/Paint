import 'dashboard_stats_model.dart';
import 'growth_model.dart';
import 'monthly_stats_model.dart';
import 'requiring_attention_model.dart';

class DashboardDataModel {
  final DashboardStatsModel statistics;
  final MonthlyStatsModel currentMonth;
  final MonthlyStatsModel? previousMonth;
  final GrowthModel growth;
  final List<RequiringAttentionModel> requiringAttention;
  final int requiringAttentionCount;

  const DashboardDataModel({
    required this.statistics,
    required this.currentMonth,
    this.previousMonth,
    required this.growth,
    required this.requiringAttention,
    required this.requiringAttentionCount,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      statistics: DashboardStatsModel.fromJson(json['statistics'] ?? {}),
      currentMonth: MonthlyStatsModel.fromJson(json['current_month'] ?? {}),
      previousMonth: json['previous_month'] != null
          ? MonthlyStatsModel.fromJson(json['previous_month'])
          : null,
      growth: GrowthModel.fromJson(json['growth'] ?? {}),
      requiringAttention:
          (json['requiring_attention'] as List?)
              ?.map((item) => RequiringAttentionModel.fromJson(item))
              .toList() ??
          [],
      requiringAttentionCount: json['requiring_attention_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'statistics': statistics.toJson(),
      'current_month': currentMonth.toJson(),
      'previous_month': previousMonth?.toJson(),
      'growth': growth.toJson(),
      'requiring_attention': requiringAttention
          .map((item) => item.toJson())
          .toList(),
      'requiring_attention_count': requiringAttentionCount,
    };
  }
}
