class CreateContactRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final List<String>? tags;
  final List<Map<String, dynamic>>? customFields;

  CreateContactRequest({
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.tags,
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Add required field (name required)
    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }

    // Add optional fields
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (companyName != null) json['companyName'] = companyName;
    if (address != null) json['address1'] = address; // API expects address1
    if (city != null) json['city'] = city;
    if (state != null) json['state'] = state;
    if (postalCode != null) json['postalCode'] = postalCode;
    if (country != null) json['country'] = country;
    if (tags != null && tags!.isNotEmpty) json['tags'] = tags;
    if (customFields != null && customFields!.isNotEmpty) {
      json['customFields'] = customFields;
    }

    return json;
  }
}
