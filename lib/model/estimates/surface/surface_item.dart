/// Individual surface item (wall, ceiling, trim piece)
class SurfaceItem {
  final String id;
  final num? width;
  final num? height;
  final num? openingsArea;
  final num? netArea;
  final String unit;

  SurfaceItem({
    required this.id,
    this.width,
    this.height,
    this.openingsArea,
    this.netArea,
    this.unit = 'sqft',
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'id': id,
      'unit': unit,
    };

    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    if (openingsArea != null) json['openings_area'] = openingsArea;
    if (netArea != null) json['net_area'] = netArea;

    return json;
  }

  factory SurfaceItem.fromJson(Map<String, dynamic> json) {
    return SurfaceItem(
      id: json['id'] ?? '',
      width: json['width'],
      height: json['height'],
      openingsArea: json['openings_area'],
      netArea: json['net_area'],
      unit: json['unit'] ?? 'sqft',
    );
  }
}
