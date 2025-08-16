import '../../domain/repository/contact_repository.dart';
import '../../model/contact_model.dart';
import '../../service/contact_service.dart';
import '../../utils/result/result.dart';

class ContactRepository implements IContactRepository {
  final ContactService _contactService;

  ContactRepository({required ContactService contactService}) 
    : _contactService = contactService;

  @override
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) {
    return _contactService.getContacts(limit: limit, offset: offset);
  }

  @override
  Future<Result<ContactModel>> createContact({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) {
    return _contactService.createContact(
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<Result<ContactModel>> getContact(String contactId) {
    return _contactService.getContact(contactId);
  }

  @override
  Future<Result<ContactModel>> updateContact(
    String contactId, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) {
    return _contactService.updateContact(
      contactId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phone: phone,
    );
  }

  @override
  Future<Result<bool>> deleteContact(String contactId) {
    return _contactService.deleteContact(contactId);
  }

  @override
  Future<Result<ContactListResponse>> searchContacts(String query) {
    return _contactService.searchContacts(query);
  }
}