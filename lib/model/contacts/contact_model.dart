import 'dart:developer';

enum SyncStatus { synced, pending, error }

class ContactModel {
  final int? localId;
  final String? id;
  final String? ghlId;
  final String? locationId;
  final String name;
  final String email;
  final String phone;
  final String? phoneLabel;
  final List<String>? additionalEmails;
  final List<String>? additionalPhones;
  final String? companyName;
  final String? businessName;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final List<Map<String, dynamic>>? customFields;
  final List<String>? tags;
  final String? type;
  final String? source;
  final bool? dnd;
  final List<Map<String, dynamic>>? dndSettings;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final String? syncError;
  final DateTime? ghlCreatedAt;
  final DateTime? ghlUpdatedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    this.localId,
    this.id,
    this.ghlId,
    this.locationId,
    required this.name,
    required this.email,
    required this.phone,
    this.phoneLabel,
    this.additionalEmails,
    this.additionalPhones,
    this.companyName,
    this.businessName,
    required this.address,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.customFields,
    this.tags,
    this.type,
    this.source,
    this.dnd,
    this.dndSettings,
    this.syncStatus = SyncStatus.synced,
    this.lastSyncedAt,
    this.syncError,
    this.ghlCreatedAt,
    this.ghlUpdatedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    // Handle name field - combine firstName and lastName from API response
    String fullName = '';
    if (json['firstName'] != null || json['lastName'] != null) {
      final firstName = json['firstName'] ?? '';
      final lastName = json['lastName'] ?? '';
      fullName = [
        firstName,
        lastName,
      ].where((part) => part.isNotEmpty).join(' ');
    } else if (json['name'] != null) {
      fullName = json['name']; // Fallback to legacy name field
    }

    // Debug log for contact creation
    if (fullName.isNotEmpty) {
      log(
        'ContactModel.fromJson: Creating contact - Name: $fullName, ID: ${json['id']}, GHL ID: ${json['ghlId'] ?? json['id']}',
      );
    }

    return ContactModel(
      id: json['id'],
      ghlId: json['ghlId'] ?? json['id'],
      locationId: json['locationId'],
      name: fullName,
      email: json['email'] ?? '',
      phone: json['phoneNo'] ?? json['phone'] ?? '',
      phoneLabel: json['phoneLabel'],
      additionalEmails: json['additionalEmails'] != null
          ? List<String>.from(json['additionalEmails'])
          : null,
      additionalPhones: json['additionalPhones'] != null
          ? List<String>.from(json['additionalPhones'])
          : null,
      companyName: json['companyName'] ?? '',
      businessName: json['businessName'],
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      postalCode: json['postalCode'] ?? '',
      country: json['country'] ?? '',
      customFields: json['customFields'] != null
          ? List<Map<String, dynamic>>.from(json['customFields'])
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      type: json['type'],
      source: json['source'],
      dnd: json['dnd'],
      dndSettings: json['dndSettings'] != null
          ? List<Map<String, dynamic>>.from(json['dndSettings'])
          : null,
      ghlCreatedAt: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : null,
      ghlUpdatedAt: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    // Split name into firstName and lastName for API compatibility
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    return {
      'id': id,
      'ghlId': ghlId,
      'locationId': locationId,
      'name': name,
      'firstName': firstName.isNotEmpty ? firstName : null,
      'lastName': lastName.isNotEmpty ? lastName : null,
      'email': email,
      'phoneNo': phone,
      'phoneLabel': phoneLabel,
      'additionalEmails': additionalEmails,
      'additionalPhones': additionalPhones,
      'companyName': companyName,
      'businessName': businessName,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'customFields': customFields,
      'tags': tags,
      'type': type,
      'source': source,
      'dnd': dnd,
      'dndSettings': dndSettings,
      'dateAdded': ghlCreatedAt?.toIso8601String(),
      'dateUpdated': ghlUpdatedAt?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      localId: map['id'],
      ghlId: map['ghl_id'],
      locationId: map['location_id'],
      name:
          [
            map['first_name'] ?? '',
            map['last_name'] ?? '',
          ].where((e) => e.isNotEmpty).join(' ').isNotEmpty
          ? [
              map['first_name'] ?? '',
              map['last_name'] ?? '',
            ].where((e) => e.isNotEmpty).join(' ')
          : (map['name'] ?? ''), // Fallback to legacy name field
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      phoneLabel: map['phone_label'],
      additionalEmails: map['additional_emails'] != null
          ? List<String>.from(
              (map['additional_emails'] as String)
                  .split(',')
                  .where((e) => e.isNotEmpty),
            )
          : null,
      additionalPhones: map['additional_phones'] != null
          ? List<String>.from(
              (map['additional_phones'] as String)
                  .split(',')
                  .where((e) => e.isNotEmpty),
            )
          : null,
      companyName: map['company_name'] ?? '',
      businessName: map['business_name'],
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      postalCode: map['postal_code'] ?? '',
      country: map['country'] ?? '',
      customFields: map['custom_fields'] != null
          ? List<Map<String, dynamic>>.from(
              (map['custom_fields'] as String)
                  .split('|')
                  .where((e) => e.isNotEmpty)
                  .map((e) {
                    final parts = e.split(':');
                    return {
                      'field': parts[0],
                      'value': parts.length > 1 ? parts[1] : '',
                    };
                  }),
            )
          : null,
      tags: map['tags'] != null
          ? List<String>.from(
              (map['tags'] as String).split(',').where((e) => e.isNotEmpty),
            )
          : null,
      type: map['type'],
      source: map['source'],
      dnd: map['dnd'] == 1,
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.name == map['sync_status'],
        orElse: () => SyncStatus.synced,
      ),
      lastSyncedAt: map['last_synced_at'] != null
          ? DateTime.parse(map['last_synced_at'])
          : null,
      syncError: map['sync_error'],
      ghlCreatedAt: map['ghl_created_at'] != null
          ? DateTime.parse(map['ghl_created_at'])
          : null,
      ghlUpdatedAt: map['ghl_updated_at'] != null
          ? DateTime.parse(map['ghl_updated_at'])
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    // Split name into first_name and last_name for database compatibility
    final nameParts = name.trim().split(' ');
    final firstName = nameParts.isNotEmpty ? nameParts.first : '';
    final lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : '';

    return {
      'ghl_id': ghlId,
      'location_id': locationId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'phone_label': phoneLabel,
      'additional_emails': additionalEmails?.join(','),
      'additional_phones': additionalPhones?.join(','),
      'company_name': companyName,
      'business_name': businessName,
      'address': address,
      'city': city,
      'state': state,
      'postal_code': postalCode,
      'country': country,
      'custom_fields': customFields
          ?.map((e) => '${e['field']}:${e['value']}')
          .join('|'),
      'tags': tags?.join(','),
      'type': type,
      'source': source,
      'dnd': dnd == true ? 1 : 0,
      'sync_status': syncStatus.name,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'sync_error': syncError,
      'ghl_created_at': ghlCreatedAt?.toIso8601String(),
      'ghl_updated_at': ghlUpdatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String get fullName {
    if (name.isNotEmpty) return name;
    return 'Sem nome';
  }

  ContactModel copyWith({
    int? localId,
    String? id,
    String? ghlId,
    String? locationId,
    String? name,
    String? email,
    String? phone,
    String? phoneLabel,
    List<String>? additionalEmails,
    List<String>? additionalPhones,
    String? companyName,
    String? businessName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
    String? type,
    String? source,
    bool? dnd,
    List<Map<String, dynamic>>? dndSettings,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    String? syncError,
    DateTime? ghlCreatedAt,
    DateTime? ghlUpdatedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContactModel(
      localId: localId ?? this.localId,
      id: id ?? this.id,
      ghlId: ghlId ?? this.ghlId,
      locationId: locationId ?? this.locationId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneLabel: phoneLabel ?? this.phoneLabel,
      additionalEmails: additionalEmails ?? this.additionalEmails,
      additionalPhones: additionalPhones ?? this.additionalPhones,
      companyName: companyName ?? this.companyName,
      businessName: businessName ?? this.businessName,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      customFields: customFields ?? this.customFields,
      tags: tags ?? this.tags,
      type: type ?? this.type,
      source: source ?? this.source,
      dnd: dnd ?? this.dnd,
      dndSettings: dndSettings ?? this.dndSettings,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      syncError: syncError ?? this.syncError,
      ghlCreatedAt: ghlCreatedAt ?? this.ghlCreatedAt,
      ghlUpdatedAt: ghlUpdatedAt ?? this.ghlUpdatedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
