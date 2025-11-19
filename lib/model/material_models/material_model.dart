import 'material_enums.dart';

class MaterialModel {
  final String id;
  final String name;
  final String code;
  final double price;
  final String priceUnit;
  final MaterialType type;
  final MaterialQuality quality;
  final String? description;
  final String? imageUrl;
  final bool isAvailable;

  MaterialModel({
    required this.id,
    required this.name,
    required this.code,
    required this.price,
    required this.priceUnit,
    required this.type,
    required this.quality,
    this.description,
    this.imageUrl,
    this.isAvailable = true,
  });

  factory MaterialModel.fromJson(Map<String, dynamic> json) {
    return MaterialModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      price: json['price']?.toDouble() ?? 0.0,
      priceUnit: json['price_unit'] ?? 'Gal',
      type: MaterialType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => MaterialType.interior,
      ),
      quality: MaterialQuality.values.firstWhere(
        (e) => e.name == json['quality'],
        orElse: () => MaterialQuality.economic,
      ),
      description: json['description'],
      imageUrl: json['image_url'],
      isAvailable: json['is_available'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'price': price,
      'price_unit': priceUnit,
      'type': type.name,
      'quality': quality.name,
      'description': description,
      'image_url': imageUrl,
      'is_available': isAvailable,
    };
  }

  MaterialModel copyWith({
    String? id,
    String? name,
    String? code,
    double? price,
    String? priceUnit,
    MaterialType? type,
    MaterialQuality? quality,
    String? brand,
    String? description,
    String? imageUrl,
    bool? isAvailable,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      price: price ?? this.price,
      priceUnit: priceUnit ?? this.priceUnit,
      type: type ?? this.type,
      quality: quality ?? this.quality,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
