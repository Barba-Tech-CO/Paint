import 'business_info.dart';

class GhlProfileData {
  final int userId;
  final String ghlLocationId;
  final BusinessInfo businessInfo;
  final DateTime? lastSync;
  final bool isVerified;

  GhlProfileData({
    required this.userId,
    required this.ghlLocationId,
    required this.businessInfo,
    this.lastSync,
    required this.isVerified,
  });

  factory GhlProfileData.fromJson(Map<String, dynamic> json) {
    return GhlProfileData(
      userId: json['user_id'],
      ghlLocationId: json['ghl_location_id'],
      businessInfo: BusinessInfo.fromJson(json['business_info']),
      lastSync: json['last_sync'] != null
          ? DateTime.parse(json['last_sync'])
          : null,
      isVerified: json['is_verified'] ?? false,
    );
  }
}
