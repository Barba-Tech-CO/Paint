class ProjectCardModel {
  final int id;
  final String title;
  final String image;
  final String floorDimensionValue;
  final String floorAreaValue;
  final String areaPaintable;
  final String? ceilingArea;
  final String? trimLength;
  final Map<String, dynamic>? roomPlanData;

  ProjectCardModel({
    required this.id,
    required this.title,
    required this.image,
    required this.floorDimensionValue,
    required this.floorAreaValue,
    required this.areaPaintable,
    this.ceilingArea,
    this.trimLength,
    this.roomPlanData,
  });

  factory ProjectCardModel.fromJson(Map<String, dynamic> json) {
    return ProjectCardModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      image: json['image'] ?? '',
      floorDimensionValue: json['floor_dimension_value'] ?? '',
      floorAreaValue: json['floor_area_value'] ?? '',
      areaPaintable: json['area_paintable'] ?? '',
      ceilingArea: json['ceiling_area'],
      trimLength: json['trim_length'],
      roomPlanData: json['room_plan_data'],
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
      'room_plan_data': roomPlanData,
    };
  }

  // Método para criar uma cópia com alterações
  ProjectCardModel copyWith({
    int? id,
    String? title,
    String? image,
    String? floorDimensionValue,
    String? floorAreaValue,
    String? areaPaintable,
    String? ceilingArea,
    String? trimLength,
    Map<String, dynamic>? roomPlanData,
  }) {
    return ProjectCardModel(
      id: id ?? this.id,
      title: title ?? this.title,
      image: image ?? this.image,
      floorDimensionValue: floorDimensionValue ?? this.floorDimensionValue,
      floorAreaValue: floorAreaValue ?? this.floorAreaValue,
      areaPaintable: areaPaintable ?? this.areaPaintable,
      ceilingArea: ceilingArea ?? this.ceilingArea,
      trimLength: trimLength ?? this.trimLength,
      roomPlanData: roomPlanData ?? this.roomPlanData,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectCardModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
