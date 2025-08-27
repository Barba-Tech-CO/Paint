import '../../model/models.dart';
import '../../utils/result/result.dart';

abstract class IContactRepository {
  /// Lista contatos com paginação (offline-first)
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  });

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
  });

  /// Obtém um contato específico (offline-first)
  Future<Result<ContactModel>> getContact(String contactId);

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
  });

  /// Remove um contato (offline-first)
  Future<Result<bool>> deleteContact(String contactId);

  /// Busca contatos por nome, email ou telefone (offline-first)
  Future<Result<ContactListResponse>> searchContacts(String query);

  /// Busca avançada de contatos (offline-first)
  Future<Result<ContactListResponse>> advancedSearch({
    String? name,
    int? pageLimit,
    int? page,
    String? query,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sort,
  });

  /// Sincroniza contatos pendentes com a API
  Future<Result<void>> syncPendingContacts();

  /// Obtém contatos por status de sincronização
  Future<Result<List<ContactModel>>> getContactsBySyncStatus(String status);
}
