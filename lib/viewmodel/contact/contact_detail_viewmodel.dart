import 'package:flutter/foundation.dart';
import '../../utils/result/result.dart';
import '../../model/contact_model.dart';
import '../../domain/repository/contact_repository.dart';

class ContactDetailViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  ContactModel? _selectedContact;
  bool _isLoading = false;
  String? _error;

  ContactDetailViewModel(this._contactRepository);

  // Getters
  ContactModel? get selectedContact => _selectedContact;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cria um novo contato
  Future<bool> createContact({
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    List<Map<String, dynamic>>? customFields,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final result = await _contactRepository.createContact(
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
        customFields: customFields,
      );

      if (result is Ok) {
        _selectedContact = result.asOk.value;
        notifyListeners();
        return true;
      } else {
        _setError(result.asError.error.toString());
        return false;
      }
    } catch (e) {
      _setError('Error creating contact: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Obtém detalhes de um contato
  Future<void> getContactDetails(String contactId) async {
    _setLoading(true);
    clearError();

    try {
      final result = await _contactRepository.getContact(contactId);
      if (result is Ok) {
        _selectedContact = result.asOk.value;
        notifyListeners();
      } else {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error getting contact details: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Atualiza um contato
  Future<bool> updateContact(
    String contactId, {
    String? name,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    List<Map<String, dynamic>>? customFields,
  }) async {
    _setLoading(true);
    clearError();

    try {
      final result = await _contactRepository.updateContact(
        contactId,
        name: name,
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
        customFields: customFields,
      );

      if (result is Ok) {
        _selectedContact = result.asOk.value;
        notifyListeners();
        return true;
      } else {
        _setError(result.asError.error.toString());
        return false;
      }
    } catch (e) {
      _setError('Error updating contact: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Remove um contato
  Future<bool> deleteContact(String contactId) async {
    _setLoading(true);
    clearError();

    try {
      final result = await _contactRepository.deleteContact(contactId);

      if (result is Ok && result.asOk.value) {
        if (_selectedContact?.id == contactId) {
          _selectedContact = null;
        }
        notifyListeners();
        return true;
      } else if (result is Error) {
        _setError(result.asError.error.toString());
      }
      return false;
    } catch (e) {
      _setError('Error deleting contact: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Seleciona um contato
  void selectContact(ContactModel contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  /// Limpa a seleção de contato
  void clearSelection() {
    _selectedContact = null;
    notifyListeners();
  }

  /// Obtém o nome completo do contato
  String get fullName {
    if (_selectedContact == null) return '';
    return _selectedContact!.fullName;
  }

  /// Obtém as iniciais do contato
  String get initials {
    if (_selectedContact == null) return '';
    final firstName = _selectedContact!.firstName?.isNotEmpty == true
        ? _selectedContact!.firstName![0].toUpperCase()
        : '';
    final lastName = _selectedContact!.lastName?.isNotEmpty == true
        ? _selectedContact!.lastName![0].toUpperCase()
        : '';
    return '$firstName$lastName';
  }

  /// Sincroniza contatos pendentes
  Future<void> syncPendingContacts() async {
    _setLoading(true);
    clearError();

    try {
      final result = await _contactRepository.syncPendingContacts();
      if (result is Error) {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error syncing pending contacts: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Métodos privados para gerenciar estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
