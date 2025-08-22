import 'business_info.dart';

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
  final bool? ghlDataIncomplete;
  final bool? ghlError;

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
    this.ghlDataIncomplete,
    this.ghlError,
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
      ghlDataIncomplete: json['ghl_data_incomplete'],
      ghlError: json['ghl_error'],
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
      'ghl_data_incomplete': ghlDataIncomplete,
      'ghl_error': ghlError,
    };
  }
}
