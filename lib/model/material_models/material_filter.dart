import 'material_enums.dart';

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
