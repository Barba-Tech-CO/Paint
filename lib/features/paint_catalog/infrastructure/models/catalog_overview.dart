import 'paint_brand.dart';

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
