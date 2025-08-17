import '../../model/contact_model.dart';
import '../../utils/result/result.dart';

abstract class IContactRepository {
  /// Lista contatos com paginação
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  });

  /// Cria um novo contato
  Future<Result<ContactModel>> createContact({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  });

  /// Obtém um contato específico
  Future<Result<ContactModel>> getContact(String contactId);

  /// Atualiza um contato
  Future<Result<ContactModel>> updateContact(
    String contactId, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  });

  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId);

  /// Busca contatos por nome ou email
  Future<Result<ContactListResponse>> searchContacts(String query);
}