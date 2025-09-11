class BusinessInfoModel {
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

  BusinessInfoModel({
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

  factory BusinessInfoModel.fromJson(Map<String, dynamic> json) {
    return BusinessInfoModel(
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
