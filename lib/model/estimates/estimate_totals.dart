/// Estimate totals model
class EstimateTotals {
  final num materialsCost;
  final num grandTotal;
  final num? laborCost;
  final num? additionalCosts;

  EstimateTotals({
    required this.materialsCost,
    required this.grandTotal,
    this.laborCost,
    this.additionalCosts,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'materials_cost': materialsCost,
      'grand_total': grandTotal,
    };

    if (laborCost != null) json['labor_cost'] = laborCost;
    if (additionalCosts != null) json['additional_costs'] = additionalCosts;

    return json;
  }

  factory EstimateTotals.fromJson(Map<String, dynamic> json) {
    return EstimateTotals(
      materialsCost: json['materials_cost'] ?? 0,
      grandTotal: json['grand_total'] ?? 0,
      laborCost: json['labor_cost'],
      additionalCosts: json['additional_costs'],
    );
  }
}
