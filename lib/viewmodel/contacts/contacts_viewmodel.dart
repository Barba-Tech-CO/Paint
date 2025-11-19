import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_model.dart';
import '../../use_case/contacts/contact_operations_use_case.dart';
import '../../utils/command/command.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

enum ContactsState { initial, loading, loaded, error }

class ContactsViewModel extends ChangeNotifier {
  final ContactOperationsUseCase _contactUseCase;
  final IContactRepository _contactRepository;
  final AppLogger _logger;

  // State
  ContactsState _state = ContactsState.initial;
  ContactsState get state => _state;

  // Data
  List<ContactModel> _contacts = [];
  List<ContactModel> get contacts => _contacts;

  set contacts(List<ContactModel> value) {
    _contacts = value;
    // Filter out contacts without names when setting contacts
    _filteredContacts = value.where((contact) {
      return contact.name.trim().isNotEmpty;
    }).toList();
    notifyListeners();
  }

  List<ContactModel> _filteredContacts = [];
  List<ContactModel> get filteredContacts => _filteredContacts;

  set filteredContacts(List<ContactModel> value) {
    _filteredContacts = value;
    notifyListeners();
  }

  ContactModel? _selectedContact;
  ContactModel? get selectedContact => _selectedContact;

  set selectedContact(ContactModel? value) {
    _selectedContact = value;
    notifyListeners();
  }

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  set searchQuery(String value) {
    if (_searchQuery != value) {
      _searchQuery = value;
      if (value.isEmpty) {
        _filteredContacts = List.from(_contacts);
        notifyListeners();
      } else {
        _searchContactsData(value);
      }
    }
  }

  // Error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  set errorMessage(String? value) {
    _errorMessage = value;
    notifyListeners();
  }

  // Loading progress
  int _loadedCount = 0;
  int get loadedCount => _loadedCount;

  String _loadingMessage = 'Loading contacts...';
  String get loadingMessage => _loadingMessage;

  ContactsViewModel(
    this._contactUseCase,
    this._contactRepository,
    this._logger,
  ) {
    // Listen to repository changes
    _contactRepository.addListener(_onRepositoryChanged);
  }

  @override
  void dispose() {
    _contactRepository.removeListener(_onRepositoryChanged);
    super.dispose();
  }

  void _onRepositoryChanged() {
    // When repository updates contacts, sync with local state
    final repositoryContacts = _contactRepository.contacts;
    if (repositoryContacts.isNotEmpty &&
        repositoryContacts.length != _contacts.length) {
      _contacts = List.from(repositoryContacts);
      // Don't overwrite filtered results if user is actively searching via API
      // API search results are more accurate than local filtering
      if (_searchQuery.isEmpty) {
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
      }
      notifyListeners();
    }
  }

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

  /// Refresh contacts from API in background
  Future<void> refreshContacts() async {
    try {
      // First sync pending contacts with API
      await _contactUseCase.syncPendingContacts();

      // Then reload contacts from local database
      if (_loadContactsCommand != null) {
        await _loadContactsCommand!.execute();
      }
    } catch (e) {
      // If sync fails, still try to reload local data
      if (_loadContactsCommand != null) {
        await _loadContactsCommand!.execute();
      }
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
    // Filter out contacts without names when clearing search
    _filteredContacts = _contacts.where((contact) {
      return contact.name.trim().isNotEmpty;
    }).toList();
    notifyListeners();
  }

  void selectContact(ContactModel? contact) {
    _selectedContact = contact;
    notifyListeners();
  }

  // Private helper methods
  void _filterContactsByQuery(String query) {
    // First, filter out contacts without names
    final contactsWithNames = _contacts.where((contact) {
      return contact.name.trim().isNotEmpty;
    }).toList();

    if (query.isEmpty) {
      _filteredContacts = contactsWithNames;
    } else {
      final searchLower = query.toLowerCase();
      _filteredContacts = contactsWithNames.where((contact) {
        final fullName = contact.name.toLowerCase();
        final phone = contact.phone.toLowerCase();
        final email = contact.email.toLowerCase();

        // Match if the search term appears as a word or at the start of a word
        // This prevents "mike" from matching "Miranda" or "Michele"
        final nameWords = fullName.split(' ');
        final matchesName = nameWords.any(
          (word) => word.startsWith(searchLower) || word == searchLower,
        );

        return matchesName ||
            phone.contains(searchLower) ||
            email.contains(searchLower);
      }).toList();
    }
  }

  // Additional helper methods
  void addContactToList(ContactModel contact) {
    _contacts.add(contact);
    _filterContactsByQuery(_searchQuery);
    notifyListeners();
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
    _contacts.removeWhere(
      (c) => c.ghlId == contactId || c.id?.toString() == contactId,
    );
    _filterContactsByQuery(_searchQuery);
    // Use Future.microtask to defer notification
    Future.microtask(() {
      notifyListeners();
    });
  }

  ContactModel? getContactById(String id) {
    try {
      // Try to find by ghlId first, then by id converted to string
      return _contacts.firstWhere(
        (contact) => contact.ghlId == id || contact.id?.toString() == id,
      );
    } catch (e) {
      return null;
    }
  }

  // Private methods - API integration through repository
  Future<Result<void>> _loadContactsData() async {
    try {
      final localContacts = _contactRepository.contacts;

      // Show local data immediately if available
      if (localContacts.isNotEmpty) {
        _contacts = List.from(localContacts);
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        _loadedCount = _contacts.length;
        _state = ContactsState.loaded;
        notifyListeners();

        // Sync in background
        _syncWithApiInBackground();
        return Result.ok(null);
      }

      // No local data - fetch from API
      _state = ContactsState.loading;
      _errorMessage = null;
      _loadedCount = 0;
      _loadingMessage = 'Loading contacts from server...';
      notifyListeners();

      final result = await _contactUseCase.getContacts(limit: 100);

      if (result is Ok) {
        final response = result.asOk.value;
        _contacts = response.contacts;
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        _loadedCount = _contacts.length;
        _state = ContactsState.loaded;
        notifyListeners();

        // Load remaining in background if needed
        if (response.total != null && response.total! > 100) {
          _loadRemainingContactsInBackground(100, response.total!);
        }

        return Result.ok(null);
      }

      // Handle error - use local data if available
      if (_contacts.isNotEmpty) {
        _state = ContactsState.loaded;
        notifyListeners();
        return Result.ok(null);
      }

      _state = ContactsState.error;
      _logger.error(
        'Failed to load contacts from API: ${result.asError.error}',
      );
      notifyListeners();
      return Result.error(
        Exception('Unable to load contacts'),
      );
    } catch (e) {
      _logger.error('Error loading contacts', e);

      // Fallback to local data if available
      if (_contacts.isNotEmpty) {
        _state = ContactsState.loaded;
        notifyListeners();
        return Result.ok(null);
      }

      _state = ContactsState.error;
      notifyListeners();
      return Result.error(
        Exception('Unable to load contacts'),
      );
    }
  }

  /// Sync with API in background without showing loading state
  Future<void> _syncWithApiInBackground() async {
    try {
      final result = await _contactUseCase.getContacts(limit: 100);

      if (result is Ok) {
        final response = result.asOk.value;
        _contacts = response.contacts;
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        _loadedCount = _contacts.length;
        notifyListeners();

        // Load remaining contacts if needed
        if (response.total != null && response.total! > 100) {
          _loadRemainingContactsInBackground(100, response.total!);
        }
      }
    } catch (e) {
      _logger.error('Background sync error: $e', e);
    }
  }

  /// Load remaining contacts in background without blocking UI
  Future<void> _loadRemainingContactsInBackground(
    int offset,
    int total,
  ) async {
    try {
      final result = await _contactUseCase.getContacts(
        limit: total - offset,
        offset: offset,
      );

      if (result is Ok) {
        final allContacts = [..._contacts, ...result.asOk.value.contacts];
        _contacts = allContacts;
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        _loadedCount = _contacts.length;
        notifyListeners();
      }
    } catch (e) {
      _logger.error('Background loading error: $e', e);
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
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        notifyListeners();
        return Result.ok(null);
      } else {
        _logger.error('Failed to add contact: ${result.asError.error}');
        notifyListeners();
        return Result.error(
          Exception('Failed to add contact'),
        );
      }
    } catch (e) {
      _logger.error('Error adding contact', e);
      notifyListeners();
      return Result.error(
        Exception('Failed to add contact'),
      );
    }
  }

  Future<Result<void>> _updateContactData(ContactModel contact) async {
    try {
      final contactId = contact.ghlId ?? contact.id?.toString() ?? '';
      if (contactId.isEmpty) {
        _logger.error('Contact ID is empty or null');
        notifyListeners();
        return Result.error(
          Exception('Contact ID not found'),
        );
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
          // Filter out contacts without names
          _filteredContacts = _contacts.where((contact) {
            return contact.name.trim().isNotEmpty;
          }).toList();
          notifyListeners();
        }
        return Result.ok(null);
      } else {
        _logger.error('Failed to update contact: ${result.asError.error}');
        notifyListeners();
        return Result.error(
          Exception('Failed to update contact'),
        );
      }
    } catch (e) {
      _logger.error('Error updating contact', e);
      notifyListeners();
      return Result.error(
        Exception('Failed to update contact'),
      );
    }
  }

  Future<Result<void>> _deleteContactData(String contactId) async {
    try {
      final result = await _contactUseCase.deleteContact(contactId);

      if (result is Ok) {
        // Remove by comparing both ghlId and id (as string)
        _contacts.removeWhere(
          (c) => c.ghlId == contactId || c.id?.toString() == contactId,
        );
        // Filter out contacts without names
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        notifyListeners();
        return Result.ok(null);
      } else {
        _logger.error('Failed to delete contact: ${result.asError.error}');
        notifyListeners();
        return Result.error(
          Exception('Failed to delete contact'),
        );
      }
    } catch (e) {
      _logger.error('Error deleting contact', e);
      notifyListeners();
      return Result.error(
        Exception('Failed to delete contact'),
      );
    }
  }

  Future<Result<void>> _searchContactsData(String query) async {
    try {
      if (query.isEmpty) {
        // Filter out contacts without names when clearing search
        _filteredContacts = _contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();
        notifyListeners();
        return Result.ok(null);
      }

      final result = await _contactUseCase.searchContacts(query);

      if (result is Ok) {
        final response = result.asOk.value;
        // Filter out contacts without names from search results
        _filteredContacts = response.contacts.where((contact) {
          return contact.name.trim().isNotEmpty;
        }).toList();

        // Update the main contacts list with new contacts from API search
        for (final contact in response.contacts) {
          final existingIndex = _contacts.indexWhere(
            (c) =>
                (c.id != null && c.id == contact.id) ||
                (c.ghlId != null && c.ghlId == contact.ghlId),
          );
          if (existingIndex == -1) {
            // Add new contact to main list
            _contacts.add(contact);
          } else {
            // Update existing contact with fresh data from API
            _contacts[existingIndex] = contact;
          }
        }

        notifyListeners();
        return Result.ok(null);
      } else {
        _logger.error('Failed to search contacts: ${result.asError.error}');
        notifyListeners();
        return Result.error(
          Exception('Failed to search contacts'),
        );
      }
    } catch (e) {
      _logger.error('Error searching contacts', e);
      notifyListeners();
      return Result.error(
        Exception('Failed to search contacts'),
      );
    }
  }

  // Migrated from ContactsHelper
  /// Converts ContactModel to Map for display purposes
  Map<String, String> convertContactModelToMap(ContactModel contact) {
    return {
      'name': contact.name,
      'phone': formatPhoneForDisplay(contact.phone),
      'address': '${contact.address}, ${contact.city}, ${contact.country}'
          .replaceAll(RegExp(r',\s*,'), ',')
          .replaceAll(RegExp(r'^,\s*|,\s*$'), ''),
    };
  }

  /// Formats phone number for display
  static String formatPhoneForDisplay(String? phone) {
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

  /// Creates a debounced search function
  void createDebouncedSearch({
    required TextEditingController searchController,
    Duration delay = const Duration(milliseconds: 300),
  }) {
    Timer? debounceTimer;

    searchController.addListener(() {
      debounceTimer?.cancel();
      debounceTimer = Timer(delay, () {
        final query = searchController.text.trim();
        if (query.isEmpty) {
          filteredContacts = contacts;
        } else {
          searchContacts(query);
        }
      });
    });
  }

  /// Dismisses keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  /// Gets loading widget for contacts
  Widget getLoadingWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            _loadingMessage,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_loadedCount > 0) ...[
            const SizedBox(height: 8),
            Text(
              '$_loadedCount ${_loadedCount == 1 ? 'contact' : 'contacts'} loaded',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Gets error widget for contacts
  static Widget getErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
