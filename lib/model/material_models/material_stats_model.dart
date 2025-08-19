import 'material_price_range_model.dart';

class MaterialStatsModel {
  final int totalMaterials;
  final int availableMaterials;
  final double averagePrice;
  final MaterialPriceRangeModel priceRange;

  MaterialStatsModel({
    required this.totalMaterials,
    required this.availableMaterials,
    required this.averagePrice,
    required this.priceRange,
  });
}
