import '../../utils/json_parser_helper.dart';

class PaintBrand {
  final String key;
  final String name;
  final String? description;
  final String? logoUrl;
  final bool isPopular;

  PaintBrand({
    required this.key,
    required this.name,
    this.description,
    this.logoUrl,
    this.isPopular = false,
  });

  factory PaintBrand.fromJson(Map<String, dynamic> json) {
    return PaintBrand(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      logoUrl: json['logo_url'],
      isPopular: json['is_popular'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'is_popular': isPopular,
    };
  }
}

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

class ColorDetail {
  final String key;
  final String name;
  final String? hexCode;
  final String? rgbCode;
  final String? description;
  final List<String> usages;
  final String? imageUrl;
  final Map<String, double> prices; // size_key -> price
  final List<PaintSize> availableSizes;

  ColorDetail({
    required this.key,
    required this.name,
    this.hexCode,
    this.rgbCode,
    this.description,
    required this.usages,
    this.imageUrl,
    required this.prices,
    required this.availableSizes,
  });

  factory ColorDetail.fromJson(Map<String, dynamic> json) {
    final pricesMap = json['prices'] as Map<String, dynamic>? ?? {};
    final availableSizesList = json['available_sizes'] as List<dynamic>? ?? [];

    return ColorDetail(
      key: json['key'] ?? '',
      name: json['name'] ?? '',
      hexCode: json['hex_code'],
      rgbCode: json['rgb_code'],
      description: json['description'],
      usages: json['usages'] != null ? List<String>.from(json['usages']) : [],
      imageUrl: json['image_url'],
      prices: pricesMap.map((key, value) => MapEntry(key, value.toDouble())),
      availableSizes: availableSizesList
          .map((size) => PaintSize.fromJson(size))
          .toList(),
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
      'prices': prices,
      'available_sizes': availableSizes.map((size) => size.toJson()).toList(),
    };
  }
}

class PaintCalculation {
  final int gallonsNeeded;
  final double totalCost;
  final double area;
  final String brandKey;
  final String colorKey;
  final String usage;

  PaintCalculation({
    required this.gallonsNeeded,
    required this.totalCost,
    required this.area,
    required this.brandKey,
    required this.colorKey,
    required this.usage,
  });

  factory PaintCalculation.fromJson(Map<String, dynamic> json) {
    return PaintCalculation(
      gallonsNeeded: json['gallons_needed'] ?? 0,
      totalCost: parseDouble(json['total_cost']),
      area: json['area']?.toDouble() ?? 0.0,
      brandKey: json['brand_key'] ?? '',
      colorKey: json['color_key'] ?? '',
      usage: json['usage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gallons_needed': gallonsNeeded,
      'total_cost': totalCost,
      'area': area,
      'brand_key': brandKey,
      'color_key': colorKey,
      'usage': usage,
    };
  }
}

class CatalogOverview {
  final int totalBrands;
  final int totalColors;
  final List<PaintBrand> popularBrands;
  final Map<String, int> colorsPerBrand;

  CatalogOverview({
    required this.totalBrands,
    required this.totalColors,
    required this.popularBrands,
    required this.colorsPerBrand,
  });

  factory CatalogOverview.fromJson(Map<String, dynamic> json) {
    final popularBrandsList = json['popular_brands'] as List<dynamic>? ?? [];
    final colorsPerBrandMap =
        json['colors_per_brand'] as Map<String, dynamic>? ?? {};

    return CatalogOverview(
      totalBrands: json['total_brands'] ?? 0,
      totalColors: json['total_colors'] ?? 0,
      popularBrands: popularBrandsList
          .map((brand) => PaintBrand.fromJson(brand))
          .toList(),
      colorsPerBrand: colorsPerBrandMap.map(
        (key, value) => MapEntry(key, value as int),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_brands': totalBrands,
      'total_colors': totalColors,
      'popular_brands': popularBrands.map((brand) => brand.toJson()).toList(),
      'colors_per_brand': colorsPerBrand,
    };
  }
}

class PaintSearchResult {
  final List<PaintColor> colors;
  final int total;
  final int? limit;
  final int? offset;

  PaintSearchResult({
    required this.colors,
    required this.total,
    this.limit,
    this.offset,
  });

  factory PaintSearchResult.fromJson(Map<String, dynamic> json) {
    final colorsList = json['colors'] as List<dynamic>? ?? [];
    return PaintSearchResult(
      colors: colorsList.map((color) => PaintColor.fromJson(color)).toList(),
      total: json['total'] ?? 0,
      limit: json['limit'],
      offset: json['offset'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'colors': colors.map((color) => color.toJson()).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
    };
  }
}
