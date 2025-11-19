import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

import '../../domain/repository/contact_repository.dart';
import '../../helpers/contacts/contacts_helper.dart';
import '../../model/contacts/contact_model.dart';
import '../../utils/command/command.dart';
import '../../utils/error_utils.dart';
import '../../utils/result/result.dart';
import '../../utils/snackbar_utils.dart';

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
          .where((c) => c.id == _selectedContact!.id)
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
      ? ErrorUtils.getUserFriendlyMessage(
          (_createContactCommand.result as Error).error,
        )
      : _getContactDetailsCommand.result is Error
      ? ErrorUtils.getUserFriendlyMessage(
          (_getContactDetailsCommand.result as Error).error,
        )
      : _updateContactCommand.result is Error
      ? ErrorUtils.getUserFriendlyMessage(
          (_updateContactCommand.result as Error).error,
        )
      : _deleteContactCommand.result is Error
      ? ErrorUtils.getUserFriendlyMessage(
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
      // Check by both ghlId and id (converted to string)
      if (_selectedContact?.ghlId == contactId ||
          _selectedContact?.id?.toString() == contactId) {
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

  // Migrated from ContactDetailsHelper
  /// Gets display value for contact fields, showing 'N/A' for empty values
  static String getDisplayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'N/A';
    }
    return value;
  }

  /// Checks if contact has additional business information
  static bool hasAdditionalBusinessInfo(ContactModel contact) {
    final hasCompanyName = contact.companyName?.isNotEmpty ?? false;
    final hasBusinessName = contact.businessName?.isNotEmpty ?? false;
    final hasType = contact.type?.isNotEmpty ?? false;
    return hasCompanyName || hasBusinessName || hasType;
  }

  /// Gets contact name display style
  static TextStyle getContactNameStyle(ThemeData theme) {
    return theme.textTheme.headlineMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.primaryColor,
        ) ??
        const TextStyle();
  }

  /// Gets section header data for contact information
  static Map<String, dynamic> getContactSectionData() {
    return {
      'icon': Icons.contact_phone,
      'title': 'Contact',
    };
  }

  /// Gets section header data for address information
  static Map<String, dynamic> getAddressSectionData() {
    return {
      'icon': Icons.home,
      'title': 'Address',
    };
  }

  /// Gets section header data for additional business information
  static Map<String, dynamic> getAdditionalInfoSectionData() {
    return {
      'icon': Icons.business,
      'title': 'Additional Info',
    };
  }

  /// Gets contact information rows
  static List<Map<String, String>> getContactInfoRows(ContactModel contact) {
    return [
      {
        'label': 'Email',
        'value': getDisplayValue(contact.email),
      },
      {
        'label': 'Phone',
        'value': getDisplayValue(_formatPhoneForDisplay(contact.phone)),
      },
    ];
  }

  /// Gets address information rows
  static List<Map<String, String>> getAddressInfoRows(ContactModel contact) {
    return [
      {
        'label': 'Street',
        'value': getDisplayValue(contact.address),
      },
      {
        'label': 'City',
        'value': getDisplayValue(contact.city),
      },
      {
        'label': 'State',
        'value': getDisplayValue(contact.state),
      },
      {
        'label': 'Postal Code',
        'value': getDisplayValue(contact.postalCode),
      },
      {
        'label': 'Country',
        'value': getDisplayValue(contact.country),
      },
    ];
  }

  /// Gets additional business information rows
  static List<Map<String, String>> getAdditionalInfoRows(ContactModel contact) {
    return [
      {
        'label': 'Company',
        'value': getDisplayValue(contact.companyName),
      },
      {
        'label': 'Business Name',
        'value': getDisplayValue(contact.businessName),
      },
      {
        'label': 'Type',
        'value': getDisplayValue(contact.type),
      },
    ];
  }

  /// Formats phone number for display - helper method
  static String _formatPhoneForDisplay(String? phone) {
    if (phone == null || phone.isEmpty) return '';

    // Remove all non-digit characters
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');

    // Format as (XXX) XXX-XXXX for 10 digits
    if (digits.length == 10) {
      return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
    }

    // Return original if not 10 digits
    return phone;
  }

  // Migrated from EditContactHelper - Validation methods
  /// Validates phone number format
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    // Remove all non-digit characters for validation
    final digitsOnly = value.replaceAll(
      RegExp(r'[^\d]'),
      '',
    );
    // Check if it's a valid US phone number (10 digits or 11 starting with 1)
    if (digitsOnly.length == 10) {
      return null;
    } else if (digitsOnly.length == 11 && digitsOnly.startsWith('1')) {
      return null;
    } else {
      return 'Please enter a valid US phone number ((XXX) XXX-XXXX or +1 XXX XXX-XXXX)';
    }
  }

  /// Validates additional phones format
  static String? validateAdditionalPhones(String? value) {
    if (value == null || value.isEmpty) return null;

    final phones = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);

    for (final phone in phones) {
      // Remove all non-digit characters for validation
      final digitsOnly = phone.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );
      // Check if it's a valid US phone number (10 digits or 11 starting with 1)
      if (digitsOnly.length != 10 &&
          !(digitsOnly.length == 11 && digitsOnly.startsWith('1'))) {
        return 'Please enter valid US phone numbers separated by commas ((XXX) XXX-XXXX or +1 XXX XXX-XXXX)';
      }
    }
    return null;
  }

  /// Validates additional emails format
  static String? validateAdditionalEmails(String? value) {
    if (value == null || value.isEmpty) return null;
    final emails = value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    for (final email in emails) {
      final emailValidator = Validatorless.email(
        'Invalid email address',
      );
      if (emailValidator(email) != null) {
        return 'Please enter valid email addresses separated by commas';
      }
    }
    return null;
  }

  /// Gets name validation rules
  static String? Function(String?) get nameValidator => Validatorless.multiple([
    Validatorless.required('Name is required'),
    Validatorless.min(2, 'Name must be at least 2 characters'),
  ]);

  /// Gets email validation rules
  static String? Function(String?) get emailValidator =>
      Validatorless.multiple([
        Validatorless.required('Email is required'),
        Validatorless.email('Please enter a valid email'),
      ]);

  /// Gets company name validation rules (optional for edit)
  static String? Function(String?) get companyNameValidator =>
      Validatorless.min(
        3,
        'Company Name must be at least 3 characters',
      );

  /// Gets address validation rules
  static String? Function(String?) get addressValidator =>
      Validatorless.multiple([
        Validatorless.required('Address is required'),
        Validatorless.min(3, 'Address must be at least 3 characters'),
      ]);

  /// Gets city validation rules
  static String? Function(String?) get cityValidator => Validatorless.multiple([
    Validatorless.required('City is required'),
    Validatorless.min(3, 'City must be at least 3 characters'),
  ]);

  /// Gets state validation rules
  static String? Function(String?) get stateValidator =>
      Validatorless.multiple([
        Validatorless.required('State is required'),
        Validatorless.min(2, 'State must be at least 2 characters'),
      ]);

  /// Gets postal code validation rules
  static String? Function(String?) get postalCodeValidator =>
      Validatorless.multiple([
        Validatorless.required('Postal Code is required'),
        Validatorless.min(5, 'Postal Code must be at least 5 characters'),
      ]);

  /// Gets country validation rules
  static String? Function(String?) get countryValidator =>
      Validatorless.multiple([
        Validatorless.required('Country is required'),
        Validatorless.min(2, 'Country must be at least 2 characters'),
      ]);

  /// Populates form controllers with contact data
  void populateFormWithContactData({
    required ContactModel contact,
    required TextEditingController nameController,
    required TextEditingController phoneController,
    required TextEditingController additionalPhonesController,
    required TextEditingController additionalEmailsController,
    required TextEditingController emailController,
    required TextEditingController companyNameController,
    required TextEditingController addressController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    required TextEditingController zipCodeController,
    required TextEditingController countryController,
  }) {
    nameController.text = contact.name;
    phoneController.text = contact.phone;
    emailController.text = contact.email;
    companyNameController.text = contact.companyName ?? '';
    addressController.text = contact.address;
    cityController.text = contact.city;
    stateController.text = contact.state;
    zipCodeController.text = contact.postalCode;
    countryController.text = contact.country;

    // Preencher campos adicionais
    if (contact.additionalEmails != null &&
        contact.additionalEmails!.isNotEmpty) {
      additionalEmailsController.text = contact.additionalEmails!.join(', ');
    }

    if (contact.additionalPhones != null &&
        contact.additionalPhones!.isNotEmpty) {
      additionalPhonesController.text = contact.additionalPhones!.join(', ');
    }
  }

  /// Updates a contact with form data
  Future<void> updateContactWithForm({
    required GlobalKey<FormState> formKey,
    required ContactModel contact,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController additionalEmailsController,
    required TextEditingController phoneController,
    required TextEditingController additionalPhonesController,
    required TextEditingController addressController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    required TextEditingController zipCodeController,
    required TextEditingController countryController,
    required TextEditingController companyNameController,
    required BuildContext context,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Create custom fields for additional data
    final customFields = <Map<String, dynamic>>[];

    // Use ghlId for API operations, fallback to id as string
    final contactIdToUse = contact.ghlId ?? contact.id?.toString() ?? '';

    if (contactIdToUse.isEmpty) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          message: 'Contact ID not found. Cannot update contact.',
        );
      }
      return;
    }

    final shouldUpdateAPI = contact.ghlId != null;

    final result = await updateContact(
      contactIdToUse,
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      additionalEmails: additionalEmailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      phone: ContactsHelper.normalizePhoneForStorage(
        phoneController.text.trim(),
      ),
      additionalPhones: additionalPhonesController.text
          .split(',')
          .map((e) => ContactsHelper.normalizePhoneForStorage(e.trim()))
          .where((e) => e.isNotEmpty)
          .toList(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: zipCodeController.text.trim(),
      country: countryController.text.trim(),
      companyName: companyNameController.text.trim(),
      customFields: customFields.isNotEmpty ? customFields : null,
    );

    if (result is Ok) {
      // Show success message
      if (context.mounted) {
        final message = shouldUpdateAPI
            ? 'Contact updated successfully in API and locally!'
            : 'Contact updated successfully locally! (Will sync when online)';

        SnackBarUtils.showSuccess(
          context,
          message: message,
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    } else {
      // Show user-friendly error message
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          message: 'Failed to update contact. Please try again.',
        );
      }
    }
  }
}
