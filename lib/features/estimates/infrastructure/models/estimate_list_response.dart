import 'estimate_model.dart';

class EstimateListResponse {
  final List<EstimateModel> estimates;
  final int? total;
  final int? limit;
  final int? offset;

  EstimateListResponse({
    required this.estimates,
    this.total,
    this.limit,
    this.offset,
  });

  factory EstimateListResponse.fromJson(Map<String, dynamic> json) {
    final estimatesList = json['estimates'] as List<dynamic>? ?? [];
    return EstimateListResponse(
      estimates: estimatesList
          .map((estimate) => EstimateModel.fromJson(estimate))
          .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}
