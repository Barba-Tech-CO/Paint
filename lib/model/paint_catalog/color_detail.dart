import 'paint_size.dart';

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
