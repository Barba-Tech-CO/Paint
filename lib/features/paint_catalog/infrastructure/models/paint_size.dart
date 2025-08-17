class PaintSize {
  final String key;
  final String name;
  final double volume; // em litros
  final double? price;
  final String? description;

  PaintSize({
    required this.key,
    required this.name,
    required this.volume,
    this.price,
    this.description,
  });

  factory PaintSize.fromJson(Map<String, dynamic> json) {
    return PaintSize(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      volume: json['volume']?.toDouble() ?? 0.0,
      price: json['price']?.toDouble(),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'volume': volume,
      'price': price,
      'description': description,
    };
  }
}
