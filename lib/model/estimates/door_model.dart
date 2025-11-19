import '../../utils/json_parser_helper.dart';

class DoorModel {
  final double width;
  final double height;
  final double? area;

  DoorModel({
    required this.width,
    required this.height,
    this.area,
  });

  factory DoorModel.fromJson(Map<String, dynamic> json) {
    return DoorModel(
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
