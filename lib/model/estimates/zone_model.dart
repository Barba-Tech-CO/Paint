import 'zone_data_model.dart';

class ZoneModel {
  final String? id;
  final String name;
  final String zoneType; // interior | exterior | both
  final List<ZoneDataModel> data;

  ZoneModel({
    this.id,
    required this.name,
    required this.zoneType,
    required this.data,
  });
}
