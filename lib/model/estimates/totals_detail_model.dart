import '../../utils/json_parser_helper.dart';

class TotalsDetailModel {
  final double materialsCost;
  final double laborCost;
  final double equipmentCost;
  final double permitsCost;
  final double markupPercentage;
  final double markupAmount;
  final double subtotal;
  final double taxPercentage;
  final double taxAmount;
  final double discountAmount;
  final double totalCost;

  TotalsDetailModel({
    required this.materialsCost,
    required this.laborCost,
    required this.equipmentCost,
    required this.permitsCost,
    required this.markupPercentage,
    required this.markupAmount,
    required this.subtotal,
    required this.taxPercentage,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalCost,
  });

  factory TotalsDetailModel.fromJson(Map<String, dynamic> json) {
    return TotalsDetailModel(
      materialsCost: parseDouble(json['materials_cost']),
      laborCost: parseDouble(json['labor_cost']),
      equipmentCost: parseDouble(json['equipment_cost']),
      permitsCost: parseDouble(json['permits_cost']),
      markupPercentage: parseDouble(json['markup_percentage']),
      markupAmount: parseDouble(json['markup_amount']),
      subtotal: parseDouble(json['subtotal']),
      taxPercentage: parseDouble(json['tax_percentage']),
      taxAmount: parseDouble(json['tax_amount']),
      discountAmount: parseDouble(json['discount_amount']),
      totalCost: parseDouble(json['total_cost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'materials_cost': materialsCost,
      'labor_cost': laborCost,
      'equipment_cost': equipmentCost,
      'permits_cost': permitsCost,
      'markup_percentage': markupPercentage,
      'markup_amount': markupAmount,
      'subtotal': subtotal,
      'tax_percentage': taxPercentage,
      'tax_amount': taxAmount,
      'discount_amount': discountAmount,
      'total_cost': totalCost,
    };
  }
}
