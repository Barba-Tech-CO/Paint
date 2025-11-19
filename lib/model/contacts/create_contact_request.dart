class CreateContactRequest {
  final String? firstName; // API REQUIRED field
  final String? lastName; // API OPTIONAL field
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
    this.tags,
    this.customFields,
  });

  // Factory method to create from name string (for backward compatibility)
  factory CreateContactRequest.fromName({
    String? name,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<String>? tags,
    List<Map<String, dynamic>>? customFields,
  }) {
    String? firstName;
    String? lastName;

    if (name != null && name.isNotEmpty) {
      final nameParts = name.trim().split(' ');
      firstName = nameParts.isNotEmpty ? nameParts.first : null;
      lastName = nameParts.length > 1 ? nameParts.skip(1).join(' ') : null;
    }

    return CreateContactRequest(
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
      tags: tags,
      customFields: customFields,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    // Add firstName (REQUIRED) and lastName (OPTIONAL)
    if (firstName != null && firstName!.isNotEmpty) {
      json['firstName'] = firstName; // API REQUIRED field
    }
    if (lastName != null && lastName!.isNotEmpty) {
      json['lastName'] = lastName; // API OPTIONAL field
    }

    // Add optional fields
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (companyName != null) json['companyName'] = companyName;
    if (address != null) {
      json['address'] = address;
    }
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
