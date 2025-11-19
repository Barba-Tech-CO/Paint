class ZoneAddDataModel {
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;
  final String? ceilingArea;
  final String? trimLength;
  final Map<String, dynamic>? roomPlanData;

  ZoneAddDataModel({
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
    this.ceilingArea,
    this.trimLength,
    this.roomPlanData,
  });
}
