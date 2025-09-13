class UpdateContactRequest {
  final String? firstName;  // API expects firstName
  final String? lastName;   // API expects lastName
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
    this.firstName,
    this.lastName,
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

  // Factory method to create from name string (for backward compatibility)
  factory UpdateContactRequest.fromName({
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<String>? additionalEmails,
    List<String>? additionalPhones,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
  }) {
    String? firstName;
    String? lastName;
    
    if (name != null && name.isNotEmpty) {
      final nameParts = name.trim().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : null;
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : null;
    }
    
    return UpdateContactRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
      companyName: companyName,
      address: address,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      additionalEmails: additionalEmails,
      additionalPhones: additionalPhones,
      customFields: customFields,
      tags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Add firstName and lastName (API expects these fields)
    if (firstName != null && firstName!.isNotEmpty) {
      json['firstName'] = firstName;
    }
    if (lastName != null && lastName!.isNotEmpty) {
      json['lastName'] = lastName;
    }

    // Add other fields
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (companyName != null) json['companyName'] = companyName;
    if (address != null) json['address'] = address; // API expects address (not address1)
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
