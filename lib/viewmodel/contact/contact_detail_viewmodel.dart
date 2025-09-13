import 'package:flutter/foundation.dart';

import '../../domain/repository/contact_repository.dart';
import '../../helpers/error_message_helper.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

class ContactDetailViewModel extends ChangeNotifier {
  final IContactRepository _contactRepository;

  ContactModel? _selectedContact;

  // Commands for async operations
  late final Command1<ContactModel, Map<String, dynamic>> _createContactCommand;
  late final Command1<ContactModel, String> _getContactDetailsCommand;
  late final Command1<ContactModel, Map<String, dynamic>> _updateContactCommand;
  late final Command1<bool, String> _deleteContactCommand;

  ContactDetailViewModel(this._contactRepository) {
    // Initialize commands
    _createContactCommand = Command1(_createContact);
    _getContactDetailsCommand = Command1(_getContactDetails);
    _updateContactCommand = Command1(_updateContact);
    _deleteContactCommand = Command1(_deleteContact);

    // Listen to repository changes
    _contactRepository.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    _contactRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    // Update selected contact if it exists in the updated repository
    if (_selectedContact != null) {
      final updatedContact = _contactRepository.contacts
          .where((c) => c.ghlId == _selectedContact!.ghlId)
          .firstOrNull;
      if (updatedContact != null && updatedContact != _selectedContact) {
        _selectedContact = updatedContact;
        notifyListeners();
      }
    }
  }

  // Getters
  ContactModel? get selectedContact => _selectedContact;
  bool get isLoading =>
      _createContactCommand.running ||
      _getContactDetailsCommand.running ||
      _updateContactCommand.running ||
      _deleteContactCommand.running;
  String? get error => _createContactCommand.result is Error
      ? ErrorMessageHelper.getUserFriendlyMessage(
          (_createContactCommand.result as Error).error,
        )
      : _getContactDetailsCommand.result is Error
      ? ErrorMessageHelper.getUserFriendlyMessage(
          (_getContactDetailsCommand.result as Error).error,
        )
      : _updateContactCommand.result is Error
      ? ErrorMessageHelper.getUserFriendlyMessage(
          (_updateContactCommand.result as Error).error,
        )
      : _deleteContactCommand.result is Error
      ? ErrorMessageHelper.getUserFriendlyMessage(
          (_deleteContactCommand.result as Error).error,
        )
      : null;

  // Command action methods
  Future<Result<ContactModel>> _createContact(
    Map<String, dynamic> params,
  ) async {
    final result = await _contactRepository.createContact(
      name: params['name'],
      phone: params['phone'],
      additionalPhones: params['additionalPhones'],
      email: params['email'],
      additionalEmails: params['additionalEmails'],
      companyName: params['companyName'],
      address: params['address'],
      city: params['city'],
      state: params['state'],
      postalCode: params['postalCode'],
      country: params['country'],
      customFields: params['customFields'],
    );

    if (result is Ok) {
      _selectedContact = result.asOk.value;
      notifyListeners();
    }

    return result;
  }

  Future<Result<ContactModel>> _getContactDetails(String contactId) async {
    final result = await _contactRepository.getContact(contactId);

    if (result is Ok) {
      _selectedContact = result.asOk.value;
      notifyListeners();
    }

    return result;
  }

  Future<Result<ContactModel>> _updateContact(
    Map<String, dynamic> params,
  ) async {
    final contactId = params['contactId'] as String;

    // Log user action for error tracking
    ErrorMessageHelper.logUserAction(
      'Update Contact',
      {'contactId': contactId, 'hasName': params['name'] != null},
    );

    final result = await _contactRepository.updateContact(
      contactId,
      name: params['name'],
      phone: params['phone'],
      additionalPhones: params['additionalPhones'],
      email: params['email'],
      additionalEmails: params['additionalEmails'],
      companyName: params['companyName'],
      address: params['address'],
      city: params['city'],
      state: params['state'],
      postalCode: params['postalCode'],
      country: params['country'],
      customFields: params['customFields'],
    );

    if (result is Ok) {
      _selectedContact = result.asOk.value;
      notifyListeners();
    }

    return result;
  }

  Future<Result<bool>> _deleteContact(String contactId) async {
    final result = await _contactRepository.deleteContact(contactId);

    if (result is Ok && result.asOk.value) {
      if (_selectedContact?.ghlId == contactId) {
        _selectedContact = null;
        notifyListeners();
      }
    }

    return result;
  }

  /// Seleciona um contato
  void selectContact(ContactModel contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  // Public methods that return Result<T>
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
  }) async {
    await _createContactCommand.execute({
      'name': name,
      'phone': phone,
      'additionalPhones': additionalPhones,
      'email': email,
      'additionalEmails': additionalEmails,
      'companyName': companyName,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'customFields': customFields,
    });

    // Return the Result from the command
    return _createContactCommand.result!;
  }

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
  }) async {
    await _updateContactCommand.execute({
      'contactId': contactId,
      'name': name,
      'phone': phone,
      'additionalPhones': additionalPhones,
      'email': email,
      'additionalEmails': additionalEmails,
      'companyName': companyName,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'customFields': customFields,
    });

    // Return the Result from the command
    return _updateContactCommand.result!;
  }

  Future<Result<bool>> deleteContact(String contactId) async {
    await _deleteContactCommand.execute(contactId);
    // Return the Result from the command
    return _deleteContactCommand.result!;
  }

  Future<Result<ContactModel>> getContactDetails(String contactId) async {
    await _getContactDetailsCommand.execute(contactId);
    // Return the Result from the command
    return _getContactDetailsCommand.result!;
  }
}
