class MaterialModel {
  final String id;
  final String name;
  final String code;
  final double price;
  final String priceUnit;
  final MaterialType type;
  final MaterialQuality quality;
  final String brand;
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
    required this.brand,
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
      brand: json['brand'] ?? '',
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
      'brand': brand,
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
      brand: brand ?? this.brand,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}

enum MaterialType {
  interior('Interior'),
  exterior('Exterior'),
  both('Both');

  const MaterialType(this.displayName);
  final String displayName;
}

enum MaterialQuality {
  economic('Economic'),
  standard('Standard'),
  high('High'),
  premium('Premium');

  const MaterialQuality(this.displayName);
  final String displayName;
}

enum MaterialFinish {
  flat('Flat'),
  eggshell('Eggshell'),
  satin('Satin'),
  semiGloss('Semi-Gloss'),
  gloss('Gloss');

  const MaterialFinish(this.displayName);
  final String displayName;
}

class MaterialFilter {
  final String? brand;
  final MaterialType? type;
  final MaterialFinish? finish;
  final MaterialQuality? quality;
  final double? minPrice;
  final double? maxPrice;
  final String? searchTerm;

  MaterialFilter({
    this.brand,
    this.type,
    this.finish,
    this.quality,
    this.minPrice,
    this.maxPrice,
    this.searchTerm,
  });

  MaterialFilter copyWith({
    String? brand,
    MaterialType? type,
    MaterialFinish? finish,
    MaterialQuality? quality,
    double? minPrice,
    double? maxPrice,
    String? searchTerm,
  }) {
    return MaterialFilter(
      brand: brand ?? this.brand,
      type: type ?? this.type,
      finish: finish ?? this.finish,
      quality: quality ?? this.quality,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      searchTerm: searchTerm ?? this.searchTerm,
    );
  }

  bool get hasFilters {
    return brand != null ||
        type != null ||
        finish != null ||
        quality != null ||
        minPrice != null ||
        maxPrice != null ||
        (searchTerm != null && searchTerm!.isNotEmpty);
  }
}
