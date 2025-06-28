import '../utils/result/result.dart';
import '../model/contact_model.dart';
import 'http_service.dart';

class ContactService {
  final HttpService _httpService;
  static const String _baseUrl = '/api/contacts';

  ContactService(this._httpService);

  /// Lista contatos com paginação
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      final response = await _httpService.get(
        _baseUrl,
        queryParameters: {
          if (limit != null) 'limit': limit,
          if (offset != null) 'offset': offset,
        },
      );

      final contactListResponse = ContactListResponse.fromJson(response.data);
      return Result.ok(contactListResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao listar contatos: $e'));
    }
  }

  /// Cria um novo contato
  Future<Result<ContactModel>> createContact({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    try {
      final response = await _httpService.post(
        _baseUrl,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
        },
      );

      final contact = ContactModel.fromJson(response.data);
      return Result.ok(contact);
    } catch (e) {
      return Result.error(Exception('Erro ao criar contato: $e'));
    }
  }

  /// Obtém um contato específico
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      final response = await _httpService.get('$_baseUrl/$contactId');

      final contact = ContactModel.fromJson(response.data);
      return Result.ok(contact);
    } catch (e) {
      return Result.error(Exception('Erro ao obter contato: $e'));
    }
  }

  /// Atualiza um contato
  Future<Result<ContactModel>> updateContact(
    String contactId, {
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['firstName'] = firstName;
      if (lastName != null) updateData['lastName'] = lastName;
      if (email != null) updateData['email'] = email;
      if (phone != null) updateData['phone'] = phone;

      final response = await _httpService.put(
        '$_baseUrl/$contactId',
        data: updateData,
      );

      final contact = ContactModel.fromJson(response.data);
      return Result.ok(contact);
    } catch (e) {
      return Result.error(Exception('Erro ao atualizar contato: $e'));
    }
  }

  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      await _httpService.delete('$_baseUrl/$contactId');
      return Result.ok(true);
    } catch (e) {
      return Result.error(Exception('Erro ao remover contato: $e'));
    }
  }

  /// Busca contatos por nome ou email
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      final response = await _httpService.get(
        _baseUrl,
        queryParameters: {'q': query},
      );

      final contactListResponse = ContactListResponse.fromJson(response.data);
      return Result.ok(contactListResponse);
    } catch (e) {
      return Result.error(Exception('Erro ao buscar contatos: $e'));
    }
  }
}
