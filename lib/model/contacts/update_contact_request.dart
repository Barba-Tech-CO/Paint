class UpdateContactRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final List<String>? additionalEmails;
  final List<String>? additionalPhones;
  final List<Map<String, dynamic>>? customFields;
  final List<String>? tags;

  UpdateContactRequest({
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.additionalEmails,
    this.additionalPhones,
    this.customFields,
    this.tags,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Add name field (API expects name)
    if (name != null && name!.isNotEmpty) {
      json['name'] = name;
    }

    // Add other fields
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (companyName != null) json['companyName'] = companyName;
    if (address != null) json['address1'] = address; // API expects address1
    if (city != null) json['city'] = city;
    if (state != null) json['state'] = state;
    if (postalCode != null) json['postalCode'] = postalCode;
    if (country != null) json['country'] = country;
    if (additionalEmails != null) json['additionalEmails'] = additionalEmails;
    if (additionalPhones != null) json['additionalPhones'] = additionalPhones;
    if (tags != null) json['tags'] = tags;
    if (customFields != null) json['customFields'] = customFields;

    return json;
  }
}
