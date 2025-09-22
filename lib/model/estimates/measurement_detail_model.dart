import 'measurement_data_model.dart';

class MeasurementDetailModel {
  final String zoneId;
  final MeasurementDataModel measurements;

  MeasurementDetailModel({
    required this.zoneId,
    required this.measurements,
  });

  factory MeasurementDetailModel.fromJson(Map<String, dynamic> json) {
    return MeasurementDetailModel(
      zoneId: json['zone_id']?.toString() ?? '',
      measurements: MeasurementDataModel.fromJson(
        json['measurements'] ?? json,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zone_id': zoneId,
      'measurements': measurements.toJson(),
    };
  }
}
