import '../../utils/json_parser_helper.dart';

class WindowModel {
  final double width;
  final double height;
  final double? area;

  WindowModel({
    required this.width,
    required this.height,
    this.area,
  });

  factory WindowModel.fromJson(Map<String, dynamic> json) {
    return WindowModel(
      width: parseDouble(json['width']),
      height: parseDouble(json['height']),
      area: json['area'] != null ? parseDouble(json['area']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'area': area,
    };
  }
}
