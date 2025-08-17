class PaintColor {
  final String key;
  final String name;
  final String? hexCode;
  final String? rgbCode;
  final String? description;
  final List<String> usages;
  final String? imageUrl;
  final double? price;

  PaintColor({
    required this.key,
    required this.name,
    this.hexCode,
    this.rgbCode,
    this.description,
    required this.usages,
    this.imageUrl,
    this.price,
  });

  factory PaintColor.fromJson(Map<String, dynamic> json) {
    return PaintColor(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      hexCode: json['hex_code'],
      rgbCode: json['rgb_code'],
      description: json['description'],
      usages: json['usages'] != null ? List<String>.from(json['usages']) : [],
      imageUrl: json['image_url'],
      price: json['price']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'hex_code': hexCode,
      'rgb_code': rgbCode,
      'description': description,
      'usages': usages,
      'image_url': imageUrl,
      'price': price,
    };
  }
}
