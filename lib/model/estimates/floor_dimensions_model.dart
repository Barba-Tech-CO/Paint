class FloorDimensionsModel {
  final num length;
  final num width;
  final String unit; // ex: ft, m

  const FloorDimensionsModel({
    required this.length,
    required this.width,
    this.unit = 'ft',
  });
}
