import 'package:flutter/foundation.dart';

import '../../model/contacts/contact_model.dart';
import '../../service/location_service.dart';
import '../../use_case/contacts/contact_operations_use_case.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactDetailViewModel extends ChangeNotifier {
  final ContactOperationsUseCase _contactUseCase;
  final LocationService _locationService;
  final AppLogger _logger;

  ContactModel _selectedContact;
  bool _isLoading = false;
  String? _error;

  ContactDetailViewModel(
    this._contactUseCase,
    this._locationService,
    this._logger,
    ContactModel contact,
  ) : _selectedContact = contact;

  // Getters
  ContactModel get selectedContact => _selectedContact;
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

      final result = await _contactUseCase.createContact(
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
        // Log technical error to console for debugging
        _logger.error(
          'Contact creation failed: ${result.asError.error}',
          result.asError.error,
        );
        // Set user-friendly error message
        _setError(_getUserFriendlyErrorMessage(result.asError.error));
        return false;
      }
    } catch (e) {
      // Log technical error to console for debugging
      _logger.error('Exception in contact creation: $e', e);
      // Set user-friendly error message
      _setError(_getUserFriendlyErrorMessage(e));
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
      final result = await _contactUseCase.getContact(contactId);
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

      final result = await _contactUseCase.updateContact(
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
      final result = await _contactUseCase.deleteContact(contactId);

      if (result is Ok && result.asOk.value) {
        if (_selectedContact.id == contactId) {
          // Contact was deleted, but we can't clear it since it's required
          // This should be handled by the calling code
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

  /// Obtém o nome completo do contato
  String get fullName {
    return _selectedContact.fullName;
  }

  /// Obtém as iniciais do contato
  String get initials {
    final name = _selectedContact.name;
    if (name.isEmpty) return '';

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
      final result = await _contactUseCase.syncPendingContacts();
      if (result is Error) {
        _setError(result.asError.error.toString());
      }
    } catch (e) {
      _setError('Error syncing pending contacts: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Converts technical errors to user-friendly messages
  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    // Log the full technical error for debugging
    _logger.error('Technical error: $error', error);

    // Map common error types to friendly messages
    if (errorString.contains('location id not available')) {
      return 'Please log in again to continue.';
    } else if (errorString.contains('database') ||
        errorString.contains('sql')) {
      return 'Unable to save contact. Please try again.';
    } else if (errorString.contains('network') ||
        errorString.contains('connection')) {
      return 'Network connection issue. Please check your internet and try again.';
    } else if (errorString.contains('authentication') ||
        errorString.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    } else if (errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return 'Please check your information and try again.';
    } else if (errorString.contains('method not allowed') ||
        errorString.contains('405')) {
      return 'Contact saved locally. Will sync when connection is restored.';
    } else if (errorString.contains('endpoint not found') ||
        errorString.contains('404')) {
      return 'Contact saved locally. Will sync when connection is restored.';
    } else {
      return 'Contact saved locally. Will sync when connection is restored.';
    }
  }

  /// Gets a user-friendly error message
  String get userFriendlyError =>
      _error != null ? _getUserFriendlyErrorMessage(_error) : '';

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
