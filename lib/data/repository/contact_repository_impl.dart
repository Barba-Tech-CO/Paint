import 'dart:async';

import '../../config/dependency_injection.dart';
import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_list_response.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/auth_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../service/http_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactRepository extends IContactRepository {
  final ContactService _contactService;
  final ContactDatabaseService _databaseService;
  final AuthService _authService;
  final AppLogger _logger;

  // Source of truth - internal state
  List<ContactModel> _contacts = [];
  Completer<void>? _initializationCompleter;
  bool _isSyncing = false;

  @override
  List<ContactModel> get contacts => List.unmodifiable(_contacts);

  @override
  int get contactsCount => _contacts.length;

  ContactRepository({
    required ContactService contactService,
    required ContactDatabaseService databaseService,
    required AuthService authService,
    required AppLogger logger,
  }) : _contactService = contactService,
       _databaseService = databaseService,
       _authService = authService,
       _logger = logger {
    _initializeFromDatabase();
  }

  /// Initialize contacts from local database
  Future<void> _initializeFromDatabase() async {
    try {
      _initializationCompleter = Completer<void>();

      // Get current user ID
      int? userId;
      try {
        final userResult = await _authService.getUser();
        if (userResult is Ok) {
          userId = userResult.asOk.value.id;
        }
      } catch (e) {
        _logger.warning('Failed to get user ID for contact initialization: $e');
      }

      final localContacts = await _databaseService.getAllContacts(
        userId: userId,
      );

      _contacts = localContacts;

      notifyListeners();

      _syncWithApiInBackground();
    } catch (e) {
      _logger.error('Failed to initialize contacts from database: $e', e);
      _contacts = [];
    } finally {
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    }
  }

  void _updateContactInMemory(ContactModel contact) {
    // Compare by id (primary key) first, fallback to ghlId
    final index = _contacts.indexWhere(
      (c) =>
          (c.id != null && c.id == contact.id) ||
          (c.ghlId != null && c.ghlId == contact.ghlId),
    );
    if (index != -1) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    notifyListeners();
  }

  void _removeContactFromMemory(String contactId) {
    _contacts.removeWhere(
      (c) => c.ghlId == contactId || c.id?.toString() == contactId,
    );
    notifyListeners();
  }

  /// Injects userId from authenticated user into contact before saving
  Future<ContactModel> _injectUserId(ContactModel contact) async {
    if (contact.userId != null) {
      return contact; // Already has userId
    }

    try {
      final userResult = await _authService.getUser();
      if (userResult is Ok) {
        final user = userResult.asOk.value;

        return contact.copyWith(userId: user.id);
      } else {
        _logger.error('Failed to get user: ${userResult.asError.error}');
      }
    } catch (e) {
      _logger.error('Exception injecting userId: $e');
    }

    return contact;
  }

  /// Reloads contacts from database (useful after create/update operations)
  Future<void> _reloadContactsFromDatabase() async {
    try {
      int? userId;
      try {
        final userResult = await _authService.getUser();
        if (userResult is Ok) {
          userId = userResult.asOk.value.id;
        }
      } catch (e) {
        _logger.warning('Failed to get user ID for reload: $e');
      }

      final localContacts = await _databaseService.getAllContacts(
        userId: userId,
      );
      _contacts = localContacts;

      notifyListeners();
    } catch (e) {
      _logger.error('Failed to reload contacts from database: $e');
    }
  }

  @override
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      if (_initializationCompleter != null) {
        await _initializationCompleter!.future;
      }

      // Offline-first strategy: sync via API then return local data
      final syncResult = await _syncContactsFromApi();

      if (syncResult is Error) {
        _logger.warning(
          'ContactRepository: Failed to sync contacts from API: ${syncResult.asError.error}',
        );
      }

      final contactsToReturn = limit != null || offset != null
          ? _contacts.skip(offset ?? 0).take(limit ?? _contacts.length).toList()
          : _contacts;

      final response = ContactListResponse(
        contacts: contactsToReturn,
        count: contactsToReturn.length,
        total: _contacts.length,
        limit: limit,
        offset: offset,
      );

      return Result.ok(response);
    } catch (e) {
      _logger.error('Error getting contacts', e);
      return Result.error(
        Exception('Error getting contacts'),
      );
    }
  }

  @override
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
    try {
      final apiResult = await _contactService.createContact(
        name: name,
        email: email,
        phone: phone,
        additionalPhones: additionalPhones,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        customFields: customFields,
      );

      if (apiResult is Ok) {
        final contact = await _injectUserId(apiResult.asOk.value);
        await _databaseService.insertContact(contact);
        _updateContactInMemory(contact);

        // Reload all contacts from database to ensure UI sync
        await _reloadContactsFromDatabase();

        return Result.ok(contact);
      } else {
        _logger.error(
          'API call failed: ${apiResult.asError.error}',
        );
        return Result.error(apiResult.asError.error);
      }
    } catch (e) {
      _logger.error('Error creating contact', e);
      return Result.error(
        Exception('Error creating contact'),
      );
    }
  }

  @override
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      // Offline-first strategy: Always try to sync from API first
      final apiResult = await _contactService.getContact(contactId);

      if (apiResult is Ok) {
        final contact = await _injectUserId(apiResult.asOk.value);

        await _databaseService.insertContact(contact);

        _updateContactInMemory(contact);

        return Result.ok(contact);
      } else {
        _logger.warning(
          'ContactRepository: Failed to sync contact $contactId from API: ${apiResult.asError.error}',
        );

        // Only return local data if API fails - no fallback behavior
        final localContact = await _databaseService.getContact(contactId);
        if (localContact != null) {
          return Result.ok(localContact);
        }

        return Result.error(
          Exception('Contact not found locally and API sync failed'),
        );
      }
    } catch (e) {
      _logger.error(
        'ContactRepository: Error getting contact $contactId: $e',
        e,
      );

      // Only try local database as last resort
      try {
        final localContact = await _databaseService.getContact(contactId);
        if (localContact != null) {
          return Result.ok(localContact);
        }
      } catch (localError) {
        _logger.error(
          'ContactRepository: Local database error: $localError',
          localError,
        );
      }

      _logger.error(
        'ContactRepository: Error getting contact $contactId: $e',
        e,
      );
      return Result.error(
        Exception('Error getting contact'),
      );
    }
  }

  @override
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
    try {
      final currentContact = await _databaseService.getContact(contactId);
      if (currentContact == null) {
        return Result.error(
          Exception('Contact not found'),
        );
      }

      final updatedContact = currentContact.copyWith(
        name: name,
        email: email,
        phone: phone,
        additionalPhones: additionalPhones,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        customFields: customFields,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updateContact(updatedContact);
      _updateContactInMemory(updatedContact);

      final apiResult = await _contactService.updateContact(
        contactId,
        name: name,
        email: email,
        phone: phone,
        additionalPhones: additionalPhones,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address,
        city: city,
        state: state,
        postalCode: postalCode,
        country: country,
        customFields: customFields,
      );

      if (apiResult is Ok) {
        final syncedContact = apiResult.asOk.value;
        final preservedContact = _preserveContactData(
          syncedContact,
          updatedContact,
          currentContact,
        );

        await _databaseService.updateContact(preservedContact);
        await _databaseService.updateSyncStatus(
          preservedContact.ghlId!,
          SyncStatus.synced,
        );
        _updateContactInMemory(preservedContact);

        // Reload all contacts from database to ensure UI sync
        await _reloadContactsFromDatabase();

        return Result.ok(preservedContact);
      } else {
        _logger.error(
          'API sync failed, keeping contact as pending: ${apiResult.asError.error}',
        );
        return Result.ok(updatedContact);
      }
    } catch (e) {
      _logger.error('Error updating contact: $e', e);
      return Result.error(
        Exception('Error updating contact'),
      );
    }
  }

  ContactModel _preserveContactData(
    ContactModel synced,
    ContactModel updated,
    ContactModel original,
  ) {
    return synced.copyWith(
      locationId: original.locationId,
      name: _preserveField(synced.name, updated.name),
      address: _preserveField(synced.address, updated.address),
      city: _preserveField(synced.city, updated.city),
      state: _preserveField(synced.state, updated.state),
      postalCode: _preserveField(synced.postalCode, updated.postalCode),
    );
  }

  String _preserveField(String syncedValue, String updatedValue) {
    return (syncedValue.isEmpty || syncedValue == 'null')
        ? updatedValue
        : syncedValue;
  }

  @override
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      final currentContact = await _databaseService.getContact(contactId);
      if (currentContact != null) {
        await _databaseService.updateSyncStatus(contactId, SyncStatus.pending);
      }

      final apiResult = await _contactService.deleteContact(contactId);
      if (apiResult is Ok) {
        await _databaseService.deleteContact(contactId);
      }

      _removeContactFromMemory(contactId);
      return Result.ok(true);
    } catch (e) {
      _logger.error('Error deleting contact: $e', e);
      return Result.error(
        Exception('Error deleting contact'),
      );
    }
  }

  @override
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      // Offline-first strategy: Always try to search in API first
      final apiResult = await _contactService.searchContacts(query);

      if (apiResult is Ok) {
        final apiResponse = apiResult.asOk.value;

        // Update local database with API results
        for (final contact in apiResponse.contacts) {
          try {
            final contactWithUserId = await _injectUserId(contact);
            await _databaseService.insertContact(contactWithUserId);
          } catch (e) {
            _logger.warning('Failed to save contact to local database: $e');
          }
        }
        return Result.ok(apiResponse);
      } else {
        _logger.warning(
          'ContactRepository: API search failed: ${apiResult.asError.error}',
        );
      }

      // Only search locally if API fails - no fallback behavior
      final localContacts = await _databaseService.searchContacts(query);
      final response = ContactListResponse(
        contacts: localContacts,
        count: localContacts.length,
        total: localContacts.length,
      );
      return Result.ok(response);
    } catch (e) {
      _logger.error('ContactRepository: Error searching contacts: $e', e);
      return Result.error(
        Exception('Error searching contacts'),
      );
    }
  }

  @override
  Future<Result<ContactListResponse>> advancedSearch({
    String? name,
    int? pageLimit,
    int? page,
    String? query,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sort,
  }) async {
    try {
      // Offline-first strategy: Always try API first
      final apiResult = await _contactService.advancedSearch(
        pageLimit: pageLimit,
        page: page,
        query: query,
        filters: filters,
        sort: sort,
      );

      if (apiResult is Ok) {
        final response = apiResult.asOk.value;

        // Save API results to local database
        for (final contact in response.contacts) {
          final contactWithUserId = await _injectUserId(contact);
          await _databaseService.insertContact(contactWithUserId);
        }
        return Result.ok(response);
      } else {
        _logger.warning(
          'ContactRepository: Advanced search API failed: ${apiResult.asError.error}',
        );
        return apiResult;
      }
    } catch (e) {
      _logger.error('ContactRepository: Error in advanced search: $e', e);
      return Result.error(
        Exception('Error in advanced search'),
      );
    }
  }

  @override
  Future<Result<void>> syncPendingContacts() async {
    try {
      final pendingContacts = await _databaseService.getPendingContacts();

      for (final contact in pendingContacts) {
        try {
          await _syncContactWithApi(contact);
        } catch (e) {
          _logger.error('Failed to sync contact ${contact.ghlId}: $e', e);
        }
      }

      return Result.ok(null);
    } catch (e) {
      _logger.error('Error syncing pending contacts: $e', e);
      return Result.error(
        Exception('Error syncing contacts'),
      );
    }
  }

  @override
  Future<Result<List<ContactModel>>> getContactsBySyncStatus(
    String status,
  ) async {
    try {
      final syncStatus = SyncStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => SyncStatus.synced,
      );
      final contacts = await _databaseService.getContactsBySyncStatus(
        syncStatus,
      );
      return Result.ok(contacts);
    } catch (e) {
      _logger.error('Error getting contacts by status: $e', e);
      return Result.error(
        Exception('Error getting contacts by status'),
      );
    }
  }

  // Private helper methods
  /// Check if user is authenticated before making API calls
  Future<bool> _isUserAuthenticated() async {
    try {
      final authPersistenceService = getIt<AuthPersistenceService>();
      return await authPersistenceService.isUserAuthenticated();
    } catch (e) {
      _logger.warning('Error checking authentication status: $e');
      return false;
    }
  }

  Future<Result<void>> _syncWithApiInBackground() async {
    try {
      // Prevent multiple simultaneous sync attempts
      if (_isSyncing) {
        return Result.ok(null);
      }

      // Check if user is authenticated before attempting API sync
      final isAuthenticated = await _isUserAuthenticated();
      if (!isAuthenticated) {
        return Result.ok(null);
      }

      // Ensure token is initialized before checking availability
      final httpService = getIt<HttpService>();
      await httpService.initializeAuthToken();

      final token = httpService.ghlToken;

      if (token == null || token.isEmpty) {
        return Result.ok(null);
      }

      _isSyncing = true;
      try {
        return await _syncContactsFromApi();
      } finally {
        _isSyncing = false;
      }
    } catch (e) {
      _isSyncing = false;
      _logger.error('Background sync error: $e', e);
      // Don't return error for background sync failures to prevent UI disruption
      return Result.ok(null);
    }
  }

  Future<Result<void>> _syncContactsFromApi() async {
    _logger.info('=== ContactRepository: Starting sync from API ===');

    try {
      // 1) Trigger backend sync (GHL -> API DB if available, or local contacts)
      _logger.info(
        'ContactRepository: Step 1 - Triggering backend sync (GHL -> API DB)',
      );
      final syncStopwatch = Stopwatch()..start();

      final syncResult = await _contactService.syncContacts(limit: 100);
      syncStopwatch.stop();

      if (syncResult is Ok) {
        final syncData = syncResult.asOk.value;
        _logger.info(
          'ContactRepository: Backend sync completed successfully in ${syncStopwatch.elapsedMilliseconds}ms',
        );
        _logger.info('ContactRepository: Sync stats: $syncData');
      } else if (syncResult is Error) {
        _logger.warning(
          'ContactRepository: Backend sync failed: ${syncResult.asError.error}',
        );
        _logger.warning('ContactRepository: Continuing with local fetch...');
      }

      // 2) Fetch ONLY 100 contacts from API (single page, DB+GHL) and save locally
      _logger.info(
        'ContactRepository: Step 2 - Fetching contacts from API (limit: 100)',
      );
      final fetchStopwatch = Stopwatch()..start();

      final listResult = await _contactService.getContacts(
        limit: 100,
        offset: 0,
      );

      fetchStopwatch.stop();
      _logger.info(
        'ContactRepository: API fetch completed in ${fetchStopwatch.elapsedMilliseconds}ms',
      );

      if (listResult is Ok<ContactListResponse>) {
        final fetchedContacts = listResult.asOk.value.contacts;
        _logger.info(
          'ContactRepository: Received ${fetchedContacts.length} contacts from API',
        );

        final contactsWithUserId = <ContactModel>[];
        final dbStopwatch = Stopwatch()..start();

        for (final c in fetchedContacts) {
          final contactWithUserId = await _injectUserId(c);
          await _databaseService.insertContact(contactWithUserId);
          contactsWithUserId.add(contactWithUserId);
        }

        dbStopwatch.stop();
        _logger.info(
          'ContactRepository: Saved ${contactsWithUserId.length} contacts to local DB in ${dbStopwatch.elapsedMilliseconds}ms',
        );

        // Merge fetched contacts with existing ones instead of replacing
        _logger.info('ContactRepository: Merging contacts...');
        _logger.info(
          'ContactRepository: Existing contacts before merge: ${_contacts.length}',
        );

        // Create a map of existing contacts for quick lookup
        final existingContactsMap = <String, ContactModel>{};
        for (final contact in _contacts) {
          final key = contact.ghlId ?? contact.id?.toString() ?? '';
          if (key.isNotEmpty) {
            existingContactsMap[key] = contact;
          }
        }

        // Update or add fetched contacts
        for (final fetchedContact in contactsWithUserId) {
          final key =
              fetchedContact.ghlId ?? fetchedContact.id?.toString() ?? '';
          if (key.isNotEmpty) {
            existingContactsMap[key] = fetchedContact;
          }
        }

        // Convert back to list
        _contacts = existingContactsMap.values.toList();

        _logger.info(
          'ContactRepository: Total contacts after merge: ${_contacts.length}',
        );

        notifyListeners();
        _logger.info('=== ContactRepository: Sync completed successfully ===');
        return Result.ok(null);
      } else if (listResult is Error) {
        _logger.error(
          'ContactRepository: Failed to fetch contacts: ${listResult.asError.error}',
        );
        _logger.warning('ContactRepository: Keeping existing local data');
      }

      // If API search failed, keep existing local data and don't error the flow
      _logger.info('=== ContactRepository: Sync completed (with warnings) ===');
      return Result.ok(null);
    } catch (e, stackTrace) {
      _logger.error('ContactRepository: Error syncing contacts from API');
      _logger.error('ContactRepository: Error: $e');
      _logger.error('ContactRepository: StackTrace: $stackTrace', e);
      _logger.error('=== ContactRepository: Sync failed ===');

      return Result.error(
        Exception('Error syncing contacts from database'),
      );
    }
  }

  Future<void> _syncContactWithApi(ContactModel contact) async {
    try {
      final isNewContact =
          contact.ghlId == null || contact.ghlId!.startsWith('temp');

      final result = isNewContact
          ? await _contactService.createContact(
              name: contact.name,
              email: contact.email,
              phone: contact.phone,
              companyName: contact.companyName,
              address: contact.address,
              customFields: contact.customFields,
            )
          : await _contactService.updateContact(
              contact.ghlId!,
              name: contact.name,
              email: contact.email,
              phone: contact.phone,
              companyName: contact.companyName,
              address: contact.address,
              city: contact.city,
              state: contact.state,
              postalCode: contact.postalCode,
              country: contact.country,
              customFields: contact.customFields,
            );

      if (result is Ok) {
        final syncedContact = result.asOk.value;
        await _databaseService.updateContact(syncedContact);
        await _databaseService.updateSyncStatus(
          syncedContact.ghlId!,
          SyncStatus.synced,
        );
        _updateContactInMemory(syncedContact);
      } else {
        _logger.error('Failed to sync contact: ${result.asError.error}');
        await _databaseService.updateSyncStatus(
          contact.ghlId ?? 'unknown',
          SyncStatus.error,
          error: result.asError.error.toString(),
        );
      }
    } catch (e) {
      _logger.error(
        'Exception during sync for contact ${contact.ghlId}: $e',
        e,
      );
      await _databaseService.updateSyncStatus(
        contact.ghlId ?? 'unknown',
        SyncStatus.error,
        error: e.toString(),
      );
    }
  }
}
