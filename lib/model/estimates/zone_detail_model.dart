import '../../utils/json_parser_helper.dart';

class ZoneDetailModel {
  final String id;
  final String name;
  final double area;
  final String type;
  final String color;
  final String? colorName;
  final String finish;
  final int? coats;
  final bool? primerRequired;

  ZoneDetailModel({
    required this.id,
    required this.name,
    required this.area,
    required this.type,
    required this.color,
    this.colorName,
    required this.finish,
    this.coats,
    this.primerRequired,
  });

  factory ZoneDetailModel.fromJson(Map<String, dynamic> json) {
    // Calculate area from surface_areas data
    double area = 0.0;
    if (json.containsKey('data') && json['data'] is List) {
      final dataList = json['data'] as List<dynamic>;
      if (dataList.isNotEmpty) {
        final data = dataList[0] as Map<String, dynamic>;
        if (data.containsKey('surface_areas')) {
          final surfaceAreas = data['surface_areas'] as Map<String, dynamic>;
          area =
              parseDouble(surfaceAreas['walls']) +
              parseDouble(surfaceAreas['ceiling']);
        }
      }
    }

    // Fallback to direct area field if no data structure
    if (area == 0.0) {
      area = parseDouble(json['area']);
    }

    return ZoneDetailModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      area: area,
      type: json['zone_type'] ?? json['type'] ?? '',
      color: json['color'] ?? '#FFFFFF',
      colorName: json['color_name'],
      finish: json['finish'] ?? '',
      coats: json['coats'],
      primerRequired: json['primer_required'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'area': area,
      'type': type,
      'color': color,
      'color_name': colorName,
      'finish': finish,
      'coats': coats,
      'primer_required': primerRequired,
    };
  }
}
