class BusinessInfo {
  final String name;
  final String email;
  final String? phone;
  final String? website;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final String? description;

  BusinessInfo({
    required this.name,
    required this.email,
    this.phone,
    this.website,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.description,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      website: json['website'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postal_code'],
      country: json['country'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'website': website,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'description': description,
    };
  }
}

class UserModel {
  final int id;
  final String name;
  final String email;
  final DateTime? emailVerifiedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? ghlLocationId;
  final String? ghlBusinessId;
  final String? ghlPhone;
  final String? ghlWebsite;
  final String? ghlAddress;
  final String? ghlCity;
  final String? ghlState;
  final String? ghlPostalCode;
  final String? ghlCountry;
  final String? ghlDescription;
  final DateTime? ghlLastSyncAt;
  final bool isGhlUser;
  final BusinessInfo? businessInfo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    required this.createdAt,
    required this.updatedAt,
    this.ghlLocationId,
    this.ghlBusinessId,
    this.ghlPhone,
    this.ghlWebsite,
    this.ghlAddress,
    this.ghlCity,
    this.ghlState,
    this.ghlPostalCode,
    this.ghlCountry,
    this.ghlDescription,
    this.ghlLastSyncAt,
    required this.isGhlUser,
    this.businessInfo,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      emailVerifiedAt: json['email_verified_at'] != null
          ? DateTime.parse(json['email_verified_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      ghlLocationId: json['ghl_location_id'],
      ghlBusinessId: json['ghl_business_id'],
      ghlPhone: json['ghl_phone'],
      ghlWebsite: json['ghl_website'],
      ghlAddress: json['ghl_address'],
      ghlCity: json['ghl_city'],
      ghlState: json['ghl_state'],
      ghlPostalCode: json['ghl_postal_code'],
      ghlCountry: json['ghl_country'],
      ghlDescription: json['ghl_description'],
      ghlLastSyncAt: json['ghl_last_sync_at'] != null
          ? DateTime.parse(json['ghl_last_sync_at'])
          : null,
      isGhlUser: json['is_ghl_user'] ?? false,
      businessInfo: json['business_info'] != null
          ? BusinessInfo.fromJson(json['business_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'ghl_location_id': ghlLocationId,
      'ghl_business_id': ghlBusinessId,
      'ghl_phone': ghlPhone,
      'ghl_website': ghlWebsite,
      'ghl_address': ghlAddress,
      'ghl_city': ghlCity,
      'ghl_state': ghlState,
      'ghl_postal_code': ghlPostalCode,
      'ghl_country': ghlCountry,
      'ghl_description': ghlDescription,
      'ghl_last_sync_at': ghlLastSyncAt?.toIso8601String(),
      'is_ghl_user': isGhlUser,
      'business_info': businessInfo?.toJson(),
    };
  }
}

class GhlProfileResponse {
  final bool success;
  final GhlProfileData? data;
  final String? message;

  GhlProfileResponse({
    required this.success,
    this.data,
    this.message,
  });

  factory GhlProfileResponse.fromJson(Map<String, dynamic> json) {
    return GhlProfileResponse(
      success: json['success'] ?? false,
      data: json['data'] != null ? GhlProfileData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }
}

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