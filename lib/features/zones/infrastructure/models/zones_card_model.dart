class ZonesCardModel {
  final int id;
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;
  final String? ceilingArea;
  final String? trimLength;

  ZonesCardModel({
    required this.id,
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
    this.ceilingArea,
    this.trimLength,
  });

  factory ZonesCardModel.fromJson(Map<String, dynamic> json) {
    return ZonesCardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      floorDimensionValue: json['floor_dimension_value'] ?? '',
      floorAreaValue: json['floor_area_value'] ?? '',
      areaPaintable: json['area_paintable'] ?? '',
      ceilingArea: json['ceiling_area'],
      trimLength: json['trim_length'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'image': image,
      'floor_dimension_value': floorDimensionValue,
      'floor_area_value': floorAreaValue,
      'area_paintable': areaPaintable,
      'ceiling_area': ceilingArea,
      'trim_length': trimLength,
    };
  }

  // Método para criar uma cópia com alterações
  ZonesCardModel copyWith({
    int? id,
    String? title,
    String? image,
    String? floorDimensionValue,
    String? floorAreaValue,
    String? areaPaintable,
    String? ceilingArea,
    String? trimLength,
  }) {
    return ZonesCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      floorDimensionValue: floorDimensionValue ?? this.floorDimensionValue,
      floorAreaValue: floorAreaValue ?? this.floorAreaValue,
      areaPaintable: areaPaintable ?? this.areaPaintable,
      ceilingArea: ceilingArea ?? this.ceilingArea,
      trimLength: trimLength ?? this.trimLength,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ZonesCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
