class MaterialCreateItem {
  final String id;
  final String unit;
  final num quantity;
  final num unitPrice;
  final String? name;
  final String? description;

  MaterialCreateItem({
    required this.id,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'unit': unit,
      'quantity': quantity,
      'unit_price': unitPrice,
    };

    if (name != null) json['name'] = name;
    if (description != null) json['description'] = description;

    return json;
  }

  factory MaterialCreateItem.fromJson(Map<String, dynamic> json) {
    return MaterialCreateItem(
      id: json['id'] ?? '',
      unit: json['unit'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: json['unit_price'] ?? 0,
      name: json['name'],
      description: json['description'],
    );
  }
}
