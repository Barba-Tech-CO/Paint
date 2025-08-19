class UpdateContactRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;

  UpdateContactRequest({
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.address,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (name != null) json['name'] = name;
    if (email != null) json['email'] = email;
    if (phone != null) json['phone'] = phone;
    if (companyName != null) json['companyName'] = companyName;
    if (address != null) json['address'] = address;
    return json;
  }
}