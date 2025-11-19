class SurfaceAreasModel {
  /// Áreas por superfície (chaves livres: walls, ceiling, trim, etc.)
  final Map<String, num> values;

  const SurfaceAreasModel({required this.values});

  Map<String, dynamic> toMap() {
    return Map<String, dynamic>.from(values);
  }

  factory SurfaceAreasModel.fromMap(Map<String, dynamic> map) {
    final out = <String, num>{};
    map.forEach((key, value) {
      if (value is num) {
        out[key] = value;
      } else if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) {
          out[key] = parsed;
        }
      }
    });
    return SurfaceAreasModel(values: out);
  }
}
