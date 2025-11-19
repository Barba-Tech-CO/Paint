import '../../utils/json_parser_helper.dart';

class MaterialDetailModel {
  final String id;
  final String type;
  final String? category;
  final String brand;
  final String product;
  final String? color;
  final double quantity;
  final String unit;
  final double unitPrice;
  final double totalPrice;
  final double? coverageSqft;

  MaterialDetailModel({
    required this.id,
    required this.type,
    this.category,
    required this.brand,
    required this.product,
    this.color,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.totalPrice,
    this.coverageSqft,
  });

  factory MaterialDetailModel.fromJson(Map<String, dynamic> json) {
    // Calculate total price from quantity and unit price
    final quantity = parseDouble(json['quantity']);
    final unitPrice = parseDouble(json['unit_price']);
    final totalPrice = quantity * unitPrice;

    return MaterialDetailModel(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? 'paint',
      category: json['category'],
      brand: json['brand'] ?? '',
      product: json['product'] ?? 'Paint',
      color: json['color'],
      quantity: quantity,
      unit: json['unit'] ?? '',
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      coverageSqft: json['coverage_sqft'] != null
          ? parseDouble(json['coverage_sqft'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'brand': brand,
      'product': product,
      'color': color,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'coverage_sqft': coverageSqft,
    };
  }
}
