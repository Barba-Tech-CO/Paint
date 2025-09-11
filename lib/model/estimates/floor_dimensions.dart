/// Floor dimensions model
class FloorDimensions {
  final num length;
  final num width;
  final num height;
  final String unit;

  FloorDimensions({
    required this.length,
    required this.width,
    required this.height,
    this.unit = 'ft',
  });

  Map<String, dynamic> toJson() {
    return {
      'length': length,
      'width': width,
      'height': height,
      'unit': unit,
    };
  }

  factory FloorDimensions.fromJson(Map<String, dynamic> json) {
    return FloorDimensions(
      length: json['length'] ?? 0,
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
      unit: json['unit'] ?? 'ft',
    );
  }
}
