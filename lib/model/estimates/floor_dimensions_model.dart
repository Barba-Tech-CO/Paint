class FloorDimensionsModel {
  final num length;
  final num width;
  final String unit; // ex: ft, m

  const FloorDimensionsModel({
    required this.length,
    required this.width,
    this.unit = 'ft',
  });

  Map<String, dynamic> toMap() {
    return {
      'length': length,
      'width': width,
      'unit': unit,
    };
  }

  factory FloorDimensionsModel.fromMap(Map<String, dynamic> map) {
    num parseNum(dynamic v) {
      if (v is num) return v;
      if (v is String) {
        final parsed = double.tryParse(v);
        return parsed ?? 0.0;
      }
      return 0.0;
    }

    return FloorDimensionsModel(
      length: parseNum(map['length']),
      width: parseNum(map['width']),
      unit: (map['unit'] ?? 'ft').toString(),
    );
  }
}
