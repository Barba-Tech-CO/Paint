import 'package:flutter/foundation.dart';

import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/result/result.dart';
import '../../service/location_service.dart';

class ContactDetailViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;
  final LocationService _locationService;

  ContactModel? _selectedContact;
  bool _isLoading = false;
  String? _error;

  ContactDetailViewModel(this._contactRepository, this._locationService);

  // Getters
  ContactModel? get selectedContact => _selectedContact;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentLocationId => _locationService.currentLocationId;
  bool get hasLocationId => _locationService.hasLocationId;

  /// Cria um novo contato
  Future<bool> createContact({
    String? name,
    String? phone,
    List<String?>? additionalPhones,
    String? email,
    List<String?>? additionalEmails,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    List<Map<String, dynamic>>? customFields,
  }) async {
    _setLoading(true);
    clearError();

    try {
      // Convert nullable string lists to non-nullable string lists
      final emailsList = additionalEmails
          ?.where((email) => email != null && email.isNotEmpty)
          .map((email) => email!)
          .toList();

      final phonesList = additionalPhones
          ?.where((phone) => phone != null && phone.isNotEmpty)
          .map((phone) => phone!)
          .toList();

      final result = await _contactRepository.createContact(
        name: name,
        phone: phone,
        additionalPhones: phonesList,
        email: email,
        additionalEmails: emailsList,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
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
    String? phone,
    List<String?>? additionalPhones,
    String? email,
    List<String?>? additionalEmails,
    String? companyName,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    List<Map<String, dynamic>>? customFields,
  }) async {
    _setLoading(true);
    clearError();

    try {
      // Convert nullable string lists to non-nullable string lists
      final emailsList = additionalEmails
          ?.where((email) => email != null && email.isNotEmpty)
          .map((email) => email!)
          .toList();

      final phonesList = additionalPhones
          ?.where((phone) => phone != null && phone.isNotEmpty)
          .map((phone) => phone!)
          .toList();

      final result = await _contactRepository.updateContact(
        contactId,
        name: name,
        phone: phone,
        additionalPhones: phonesList,
        email: email,
        additionalEmails: emailsList,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
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
    final name = _selectedContact!.name;
    if (name == null || name.isEmpty) return '';

    final nameParts = name.split(' ');
    if (nameParts.isEmpty) return '';

    final firstInitial = nameParts.first[0].toUpperCase();
    final lastInitial = nameParts.length > 1
        ? nameParts.last[0].toUpperCase()
        : '';

    return '$firstInitial$lastInitial';
  }

  /// Verifica se o location ID está disponível para operações da API
  bool get isLocationAvailable => _locationService.hasLocationId;

  /// Obtém informações de debug sobre o location
  String get locationDebugInfo {
    if (_locationService.hasLocationId) {
      return 'Location ID: ${_locationService.currentLocationId}';
    } else {
      return 'No location ID available';
    }
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
