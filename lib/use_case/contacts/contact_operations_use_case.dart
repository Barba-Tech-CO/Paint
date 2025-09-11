import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_list_response.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactOperationsUseCase {
  final IContactRepository _contactRepository;
  final AppLogger _logger;

  ContactOperationsUseCase(this._contactRepository, this._logger);

  /// Lista contatos com paginação (offline-first)
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      return await _contactRepository.getContacts(
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      _logger.error('Error in getContacts use case: $e', e);
      return Result.error(Exception('Failed to get contacts: $e'));
    }
  }

  /// Cria um novo contato (offline-first)
  Future<Result<ContactModel>> createContact({
    String? name,
    String? phone,
    List<String>? additionalPhones,
    String? email,
    List<String>? additionalEmails,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
  }) async {
    try {
      return await _contactRepository.createContact(
        name: name,
        phone: phone,
        additionalPhones: additionalPhones,
        email: email,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        customFields: customFields,
      );
    } catch (e) {
      _logger.error('Error in createContact use case: $e', e);
      return Result.error(Exception('Failed to create contact: $e'));
    }
  }

  /// Obtém um contato específico (offline-first)
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      return await _contactRepository.getContact(contactId);
    } catch (e) {
      _logger.error('Error in getContact use case: $e', e);
      return Result.error(Exception('Failed to get contact: $e'));
    }
  }

  /// Atualiza um contato (offline-first)
  Future<Result<ContactModel>> updateContact(
    String contactId, {
    String? name,
    String? phone,
    List<String>? additionalPhones,
    String? email,
    List<String>? additionalEmails,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    List<Map<String, dynamic>>? customFields,
    List<String>? tags,
  }) async {
    try {
      return await _contactRepository.updateContact(
        contactId,
        name: name,
        phone: phone,
        additionalPhones: additionalPhones,
        email: email,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        customFields: customFields,
      );
    } catch (e) {
      _logger.error('Error in updateContact use case: $e', e);
      return Result.error(Exception('Failed to update contact: $e'));
    }
  }

  /// Remove um contato (offline-first)
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      return await _contactRepository.deleteContact(contactId);
    } catch (e) {
      _logger.error('Error in deleteContact use case: $e', e);
      return Result.error(Exception('Failed to delete contact: $e'));
    }
  }

  /// Busca contatos por nome, email ou telefone (offline-first)
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      return await _contactRepository.searchContacts(query);
    } catch (e) {
      _logger.error('Error in searchContacts use case: $e', e);
      return Result.error(Exception('Failed to search contacts: $e'));
    }
  }

  /// Busca avançada de contatos (offline-first)
  Future<Result<ContactListResponse>> advancedSearch({
    String? name,
    int? pageLimit,
    int? page,
    String? query,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sort,
  }) async {
    try {
      return await _contactRepository.advancedSearch(
        name: name,
        pageLimit: pageLimit,
        page: page,
        query: query,
        filters: filters,
        sort: sort,
      );
    } catch (e) {
      _logger.error('Error in advancedSearch use case: $e', e);
      return Result.error(Exception('Failed to perform advanced search: $e'));
    }
  }

  /// Sincroniza contatos pendentes com a API
  Future<Result<void>> syncPendingContacts() async {
    try {
      return await _contactRepository.syncPendingContacts();
    } catch (e) {
      _logger.error('Error in syncPendingContacts use case: $e', e);
      return Result.error(Exception('Failed to sync pending contacts: $e'));
    }
  }

  /// Obtém contatos por status de sincronização
  Future<Result<List<ContactModel>>> getContactsBySyncStatus(
    String status,
  ) async {
    try {
      return await _contactRepository.getContactsBySyncStatus(status);
    } catch (e) {
      _logger.error('Error in getContactsBySyncStatus use case: $e', e);
      return Result.error(
        Exception('Failed to get contacts by sync status: $e'),
      );
    }
  }
}
