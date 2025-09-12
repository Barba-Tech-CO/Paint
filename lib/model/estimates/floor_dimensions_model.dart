class FloorDimensionsModel {
  final num length;
  final num width;
  final num height;
  final String unit; // ex: ft, m

  const FloorDimensionsModel({
    required this.length,
    required this.width,
    required this.height,
    this.unit = 'ft',
  });
}
