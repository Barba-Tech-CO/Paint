class ContactModel {
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ContactModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.createdAt,
    this.updatedAt,
  });

  factory ContactModel.fromJson(Map<String, dynamic> json) {
    return ContactModel(
      id: json['id'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      phone: json['phone'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phone': phone,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get fullName {
    final parts = <String>[];
    if (firstName?.isNotEmpty == true) parts.add(firstName!);
    if (lastName?.isNotEmpty == true) parts.add(lastName!);
    return parts.isEmpty ? 'Sem nome' : parts.join(' ');
  }
}

class ContactListResponse {
  final List<ContactModel> contacts;
  final int? total;
  final int? limit;
  final int? offset;

  ContactListResponse({
    required this.contacts,
    this.total,
    this.limit,
    this.offset,
  });

  factory ContactListResponse.fromJson(Map<String, dynamic> json) {
    final contactsList = json['contacts'] as List<dynamic>? ?? [];
    return ContactListResponse(
      contacts: contactsList
          .map((contact) => ContactModel.fromJson(contact))
          .toList(),
      total: json['total'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}
