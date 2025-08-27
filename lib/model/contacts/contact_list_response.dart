import 'contact_model.dart';

class ContactListResponse {
  final List<ContactModel> contacts;
  final int? count;
  final int? total;
  final int? limit;
  final int? offset;

  ContactListResponse({
    required this.contacts,
    this.count,
    this.total,
    this.limit,
    this.offset,
  });

  factory ContactListResponse.fromJson(Map<String, dynamic> json) {
    // Handle the API response structure - the service layer already handles success/error
    final contactsList = json['contacts'] as List<dynamic>? ?? [];
    return ContactListResponse(
      contacts: contactsList
          .map((contact) => ContactModel.fromJson(contact))
          .toList(),
      count: json['count'],
      total: json['total'] ?? json['count'],
      limit: json['limit'],
      offset: json['offset'],
    );
  }
}
