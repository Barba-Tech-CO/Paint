class EstimateElement {
  final String? brandKey;
  final String? colorKey;
  final String? usage;
  final String? sizeKey;
  final int? quantity;
  final double? unitPrice;
  final double? totalPrice;

  EstimateElement({
    this.brandKey,
    this.colorKey,
    this.usage,
    this.sizeKey,
    this.quantity,
    this.unitPrice,
    this.totalPrice,
  });

  factory EstimateElement.fromJson(Map<String, dynamic> json) {
    return EstimateElement(
      brandKey: json['brand_key'],
      colorKey: json['color_key'],
      usage: json['usage'],
      sizeKey: json['size_key'],
      quantity: json['quantity'],
      unitPrice: json['unit_price']?.toDouble(),
      totalPrice: json['total_price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand_key': brandKey,
      'color_key': colorKey,
      'usage': usage,
      'size_key': sizeKey,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
    };
  }
}
