class MaterialItemModel {
  final String? id;
  final String? unit; // ex: gallon, liter
  final num? quantity;
  final num? unitPrice;

  const MaterialItemModel({
    this.id,
    this.unit,
    this.quantity,
    this.unitPrice,
  });
}
