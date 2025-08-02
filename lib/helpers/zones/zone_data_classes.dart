// Helper classes for zone operations

class ZoneRenameData {
  final int zoneId;
  final String newName;

  ZoneRenameData({
    required this.zoneId,
    required this.newName,
  });
}

class ZoneAddData {
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;

  ZoneAddData({
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
  });
}
