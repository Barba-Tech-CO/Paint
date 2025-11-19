import 'dart:convert';
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'zone_type': zoneType,
      'data': data.map((d) => d.toMap()).toList(),
    };
  }

  factory ZoneModel.fromMap(Map<String, dynamic> map) {
    final rawData = map['data'];
    List<dynamic> dataList;
    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is String) {
      try {
        dataList = (jsonDecode(rawData) as List);
      } catch (_) {
        dataList = const [];
      }
    } else {
      dataList = const [];
    }

    return ZoneModel(
      id: map['id']?.toString(),
      name: (map['name'] ?? '').toString(),
      zoneType: (map['zone_type'] ?? '').toString(),
      data: dataList
          .map((d) => ZoneDataModel.fromMap(d as Map<String, dynamic>))
          .toList(),
    );
  }
}
