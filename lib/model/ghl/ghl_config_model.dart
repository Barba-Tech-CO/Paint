class GhlConfigModel {
  final String apiKey;
  final String locationId;
  final bool isConnected;
  final DateTime? lastSyncAt;

  const GhlConfigModel({
    required this.apiKey,
    required this.locationId,
    required this.isConnected,
    this.lastSyncAt,
  });

  factory GhlConfigModel.fromJson(Map<String, dynamic> json) {
    return GhlConfigModel(
      apiKey: json['api_key'] ?? '',
      locationId: json['location_id'] ?? '',
      isConnected: json['is_connected'] ?? false,
      lastSyncAt: json['last_sync_at'] != null
          ? DateTime.parse(json['last_sync_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'api_key': apiKey,
      'location_id': locationId,
      'is_connected': isConnected,
      'last_sync_at': lastSyncAt?.toIso8601String(),
    };
  }

  GhlConfigModel copyWith({
    String? apiKey,
    String? locationId,
    bool? isConnected,
    DateTime? lastSyncAt,
  }) {
    return GhlConfigModel(
      apiKey: apiKey ?? this.apiKey,
      locationId: locationId ?? this.locationId,
      isConnected: isConnected ?? this.isConnected,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }

  @override
  String toString() {
    return 'GhlConfigModel(apiKey: ${apiKey.isNotEmpty ? '***' : 'empty'}, locationId: $locationId, isConnected: $isConnected, lastSyncAt: $lastSyncAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GhlConfigModel &&
        other.apiKey == apiKey &&
        other.locationId == locationId &&
        other.isConnected == isConnected &&
        other.lastSyncAt == lastSyncAt;
  }

  @override
  int get hashCode {
    return apiKey.hashCode ^
        locationId.hashCode ^
        isConnected.hashCode ^
        lastSyncAt.hashCode;
  }
}
