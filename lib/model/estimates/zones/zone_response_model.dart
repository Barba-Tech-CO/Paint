import 'zone_type.dart';
import 'zone_data_response.dart';

/// Zone response model from backend
class ZoneResponseModel {
  final int id;
  final String name;
  final ZoneType? zoneType;
  final List<ZoneDataResponse> data;

  ZoneResponseModel({
    required this.id,
    required this.name,
    this.zoneType,
    required this.data,
  });

  factory ZoneResponseModel.fromJson(Map<String, dynamic> json) {
    return ZoneResponseModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      zoneType: json['zone_type'] != null
          ? ZoneType.fromString(json['zone_type'])
          : null,
      data:
          (json['data'] as List<dynamic>?)
              ?.map((d) => ZoneDataResponse.fromJson(d))
              .toList() ??
          [],
    );
  }
}
