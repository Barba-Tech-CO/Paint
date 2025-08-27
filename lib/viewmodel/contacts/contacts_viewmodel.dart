import 'package:flutter/foundation.dart';

import '../../model/models.dart';
import '../../use_case/contacts/contact_operations_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/result/result.dart';

enum ContactsState { initial, loading, loaded, error }

class ContactsViewModel extends ChangeNotifier {
  final ContactOperationsUseCase _contactUseCase;

  // State
  ContactsState _state = ContactsState.initial;
  ContactsState get state => _state;

  // Data
  List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  set contacts(List<ContactModel> value) {
    _contacts = value;
    _filteredContacts = List.from(value);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  List<ContactModel> _filteredContacts = [];
  List<ContactModel> get filteredContacts => _filteredContacts;

  set filteredContacts(List<ContactModel> value) {
    _filteredContacts = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ContactModel? _selectedContact;
  ContactModel? get selectedContact => _selectedContact;

  set selectedContact(ContactModel? value) {
    _selectedContact = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      // Use Future.microtask to defer the filtering and notification
      Future.microtask(() {
        _filterContactsByQuery(value);
        notifyListeners();
      });
    }
  }

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ContactsViewModel(this._contactUseCase);

  // Commands
  Command0<void>? _loadContactsCommand;
  Command1<void, ContactModel>? _addContactCommand;
  Command1<void, ContactModel>? _updateContactCommand;
  Command1<void, String>? _deleteContactCommand;
  Command1<void, String>? _searchContactsCommand;

  Command0<void> get loadContactsCommand => _loadContactsCommand!;
  Command1<void, ContactModel> get addContactCommand => _addContactCommand!;
  Command1<void, ContactModel> get updateContactCommand =>
      _updateContactCommand!;
  Command1<void, String> get deleteContactCommand => _deleteContactCommand!;
  Command1<void, String> get searchContactsCommand => _searchContactsCommand!;

  // Computed properties
  bool get isLoading =>
      _state == ContactsState.initial ||
      _state == ContactsState.loading ||
      (_loadContactsCommand?.running ?? false);
  bool get hasError => _state == ContactsState.error || _errorMessage != null;
  bool get hasContacts => _contacts.isNotEmpty;
  bool get hasFilteredContacts => _filteredContacts.isNotEmpty;
  int get contactsCount => _contacts.length;
  int get filteredContactsCount => _filteredContacts.length;
  bool get isSearching => _searchQuery.isNotEmpty;
  bool get isInitialized => _loadContactsCommand != null;

  // Initialize
  void initialize() {
    if (!isInitialized) {
      _initializeCommands();
      loadContacts();
    }
  }

  void _initializeCommands() {
    _loadContactsCommand = Command0(() async {
      return await _loadContactsData();
    });

    _addContactCommand = Command1((ContactModel contact) async {
      return await _addContactData(contact);
    });

    _updateContactCommand = Command1((ContactModel contact) async {
      return await _updateContactData(contact);
    });

    _deleteContactCommand = Command1((String contactId) async {
      return await _deleteContactData(contactId);
    });

    _searchContactsCommand = Command1((String query) async {
      return await _searchContactsData(query);
    });
  }

  // Public methods
  Future<void> loadContacts() async {
    if (_loadContactsCommand != null) {
      await _loadContactsCommand!.execute();
    }
  }

  Future<void> addContact(ContactModel contact) async {
    if (_addContactCommand != null) {
      await _addContactCommand!.execute(contact);
    }
  }

  Future<void> updateContact(ContactModel contact) async {
    if (_updateContactCommand != null) {
      await _updateContactCommand!.execute(contact);
    }
  }

  Future<void> deleteContact(String contactId) async {
    if (_deleteContactCommand != null) {
      await _deleteContactCommand!.execute(contactId);
    }
  }

  Future<void> searchContacts(String query) async {
    _searchQuery = query;
    if (_searchContactsCommand != null) {
      await _searchContactsCommand!.execute(query);
    }
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredContacts = List.from(_contacts);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  void selectContact(ContactModel? contact) {
    _selectedContact = contact;
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Private helper methods
  void _filterContactsByQuery(String query) {
    if (query.isEmpty) {
      _filteredContacts = List.from(_contacts);
    } else {
      final searchLower = query.toLowerCase();
      _filteredContacts = _contacts.where((contact) {
        final fullName = contact.name?.toLowerCase() ?? '';
        final phone = contact.phone?.toLowerCase() ?? '';
        final email = contact.email?.toLowerCase() ?? '';

        return fullName.contains(searchLower) ||
            phone.contains(searchLower) ||
            email.contains(searchLower);
      }).toList();
    }
  }

  // Additional helper methods
  void addContactToList(ContactModel contact) {
    _contacts.add(contact);
    _filterContactsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  void updateContactInList(ContactModel updatedContact) {
    final index = _contacts.indexWhere((c) => c.id == updatedContact.id);
    if (index != -1) {
      _contacts[index] = updatedContact;
      _filterContactsByQuery(_searchQuery);
      // Use Future.microtask to defer notification
      Future.microtask(() {
        notifyListeners();
      });
    }
  }

  void removeContactFromList(String contactId) {
    _contacts.removeWhere((c) => c.id == contactId);
    _filterContactsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ContactModel? getContactById(String id) {
    try {
      return _contacts.firstWhere((contact) => contact.id == id);
    } catch (e) {
      return null;
    }
  }

  // Private methods - API integration through repository
  Future<Result<void>> _loadContactsData() async {
    try {
      _state = ContactsState.loading;
      _errorMessage = null;
      notifyListeners();

      final result = await _contactUseCase.getContacts();

      if (result is Ok) {
        final response = result.asOk.value;
        _contacts = response.contacts;
        _filteredContacts = List.from(_contacts);
        _state = ContactsState.loaded;
        notifyListeners();
        return Result.ok(null);
      } else {
        _state = ContactsState.error;
        _errorMessage = 'Erro ao carregar contatos: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _state = ContactsState.error;
      _errorMessage = 'Erro ao carregar contatos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _addContactData(ContactModel contact) async {
    try {
      final result = await _contactUseCase.createContact(
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        additionalPhones: contact.additionalPhones,
        additionalEmails: contact.additionalEmails,
        companyName: contact.companyName,
        address: contact.address,
        city: contact.city,
        state: contact.state,
        postalCode: contact.postalCode,
        country: contact.country,
        customFields: contact.customFields,
      );

      if (result is Ok) {
        final newContact = result.asOk.value;
        _contacts.add(newContact);
        _filteredContacts = List.from(_contacts);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao adicionar contato: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao adicionar contato: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _updateContactData(ContactModel contact) async {
    try {
      final contactId = contact.ghlId ?? contact.id;
      if (contactId == null) {
        _errorMessage = 'ID do contato não encontrado';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }

      final result = await _contactUseCase.updateContact(
        contactId,
        name: contact.name,
        email: contact.email,
        phone: contact.phone,
        additionalPhones: contact.additionalPhones,
        additionalEmails: contact.additionalEmails,
        companyName: contact.companyName,
        address: contact.address,
        city: contact.city,
        state: contact.state,
        postalCode: contact.postalCode,
        country: contact.country,
        customFields: contact.customFields,
      );

      if (result is Ok) {
        final updatedContact = result.asOk.value;
        final index = _contacts.indexWhere((c) => c.id == updatedContact.id);
        if (index != -1) {
          _contacts[index] = updatedContact;
          _filteredContacts = List.from(_contacts);
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao atualizar contato: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao atualizar contato: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _deleteContactData(String contactId) async {
    try {
      final result = await _contactUseCase.deleteContact(contactId);

      if (result is Ok) {
        _contacts.removeWhere((c) => c.id == contactId);
        _filteredContacts = List.from(_contacts);
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao deletar contato: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao deletar contato: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }

  Future<Result<void>> _searchContactsData(String query) async {
    try {
      if (query.isEmpty) {
        _filteredContacts = List.from(_contacts);
        notifyListeners();
        return Result.ok(null);
      }

      final result = await _contactUseCase.searchContacts(query);

      if (result is Ok) {
        final response = result.asOk.value;
        _filteredContacts = response.contacts;
        notifyListeners();
        return Result.ok(null);
      } else {
        _errorMessage = 'Erro ao buscar contatos: ${result.asError.error}';
        notifyListeners();
        return Result.error(Exception(_errorMessage));
      }
    } catch (e) {
      _errorMessage = 'Erro ao buscar contatos: ${e.toString()}';
      notifyListeners();
      return Result.error(Exception(_errorMessage));
    }
  }
}
