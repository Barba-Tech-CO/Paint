class GhlContact {
  final String id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String? phoneNo;
  final String? phoneLabel;
  final String? email;
  final List<String>? additionalEmails;
  final List<String>? additionalPhones;
  final String? companyName;
  final String? businessName;
  final String? address;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final List<Map<String, dynamic>>? customFields;
  final List<String>? tags;
  final String? type;
  final String? source;
  final bool? dnd;
  final List<Map<String, dynamic>>? dndSettings;
  final DateTime? dateAdded;
  final DateTime? dateUpdated;
  final String? assignedTo;
  final String? locationId;
  final bool? validEmail;
  final List<dynamic>? opportunities;

  GhlContact({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    this.phoneNo,
    this.phoneLabel,
    this.email,
    this.additionalEmails,
    this.additionalPhones,
    this.companyName,
    this.businessName,
    this.address,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.customFields,
    this.tags,
    this.type,
    this.source,
    this.dnd,
    this.dndSettings,
    this.dateAdded,
    this.dateUpdated,
    this.assignedTo,
    this.locationId,
    this.validEmail,
    this.opportunities,
  });

  factory GhlContact.fromJson(Map<String, dynamic> json) {
    return GhlContact(
      id: json['id'],
      name: json['name'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      phoneNo: json['phoneNo'],
      phoneLabel: json['phoneLabel'],
      email: json['email'],
      additionalEmails: json['additionalEmails'] != null
          ? List<String>.from(json['additionalEmails'])
          : null,
      additionalPhones: json['additionalPhones'] != null
          ? List<String>.from(json['additionalPhones'])
          : null,
      companyName: json['companyName'],
      businessName: json['businessName'],
      address: json['address'],
      city: json['city'],
      state: json['state'],
      postalCode: json['postalCode'],
      country: json['country'],
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
      dateAdded: json['dateAdded'] != null
          ? DateTime.parse(json['dateAdded'])
          : null,
      dateUpdated: json['dateUpdated'] != null
          ? DateTime.parse(json['dateUpdated'])
          : null,
      assignedTo: json['assignedTo'],
      locationId: json['locationId'],
      validEmail: json['validEmail'],
      opportunities: json['opportunities'],
    );
  }
}
