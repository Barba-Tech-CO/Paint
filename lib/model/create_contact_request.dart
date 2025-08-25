class CreateContactRequest {
  final String? name;
  final String? email;
  final String? phone;
  final String? companyName;
  final String? address;
  final List<Map<String, dynamic>>? customFields;

  CreateContactRequest({
    this.name,
    this.email,
    this.phone,
    this.companyName,
    this.address,
    this.customFields,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'address': address,
      'customFields': customFields,
    };
  }
}