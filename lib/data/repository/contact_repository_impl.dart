import 'dart:async';

import '../../config/dependency_injection.dart';
import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_list_response.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../service/http_service.dart';
import '../../service/location_service.dart';
import '../../service/user_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactRepository extends IContactRepository {
  final ContactService _contactService;
  final ContactDatabaseService _databaseService;
  final LocationService _locationService;
  final UserService _userService;
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
    required LocationService locationService,
    required UserService userService,
    required AppLogger logger,
  }) : _contactService = contactService,
       _databaseService = databaseService,
       _locationService = locationService,
       _userService = userService,
       _logger = logger {
    _initializeFromDatabase();
  }

  /// Initialize contacts from local database
  Future<void> _initializeFromDatabase() async {
    try {
      _initializationCompleter = Completer<void>();
      final localContacts = await _databaseService.getAllContacts();
      _contacts = localContacts;
      _syncWithApiInBackground();
    } catch (e) {
      _logger.error('Failed to initialize contacts from database: $e', e);
      _contacts = [];
    } finally {
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    }
  }

  // Helper methods for common operations
  Future<Result<String>> _getCurrentLocationId() async {
    final locationId = _locationService.currentLocationId;
    if (locationId == null || locationId.isEmpty) {
      return Result.error(
        Exception('Location ID not available. User not authenticated.'),
      );
    }
    return Result.ok(locationId);
  }

  Future<Result<int>> _getCurrentUserId() async {
    try {
      final userResult = await _userService.getUser();
      if (userResult is Ok) {
        final user = userResult.asOk.value;
        if (user.id != null) {
          return Result.ok(user.id!);
        } else {
          return Result.error(Exception('User ID not available'));
        }
      } else {
        return Result.error(Exception('Failed to get user data'));
      }
    } catch (e) {
      return Result.error(Exception('Error getting user ID: $e'));
    }
  }

  Future<Result<String>> _validateLocationAccess(
    String contactLocationId,
  ) async {
    final locationResult = await _getCurrentLocationId();
    if (locationResult is Error) return locationResult;

    final currentLocationId = locationResult.asOk.value;
    if (contactLocationId != currentLocationId) {
      _logger.error('Contact does not belong to current user location.');
      return Result.error(
        Exception('Contact does not belong to current user location.'),
      );
    }
    return Result.ok(currentLocationId);
  }

  void _updateContactInMemory(ContactModel contact) {
    final index = _contacts.indexWhere((c) => c.ghlId == contact.ghlId);
    if (index != -1) {
      _contacts[index] = contact;
    } else {
      _contacts.add(contact);
    }
    notifyListeners();
  }

  void _removeContactFromMemory(String contactId) {
    _contacts.removeWhere((c) => c.ghlId == contactId);
    notifyListeners();
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

      // Offline-first strategy: Always try to sync from API first, then return local data
      _logger.info('ContactRepository: Attempting to sync contacts from API');
      final syncResult = await _syncContactsFromApi();

      if (syncResult is Ok) {
        _logger.info(
          'ContactRepository: Successfully synced ${_contacts.length} contacts from API',
        );
      } else {
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
      final locationResult = await _getCurrentLocationId();
      if (locationResult is Error) {
        return Result.error(locationResult.asError.error);
      }

      final tempGhlId =
          'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';
      final now = DateTime.now();

      // Get current user ID
      final userIdResult = await _getCurrentUserId();
      if (userIdResult is Error) {
        return Result.error(userIdResult.asError.error);
      }

      final tempContact = ContactModel(
        localId: userIdResult.asOk.value, // Use actual user ID
        ghlId: tempGhlId,
        locationId: locationResult.asOk.value,
        name: name ?? '',
        email: email ?? '',
        phone: phone ?? '',
        additionalPhones: additionalPhones,
        additionalEmails: additionalEmails,
        companyName: companyName,
        address: address ?? '',
        city: city ?? '',
        state: state ?? '',
        postalCode: postalCode ?? '',
        country: country ?? '',
        customFields: customFields,
        syncStatus: SyncStatus.pending,
        createdAt: now,
        updatedAt: now,
      );

      await _databaseService.insertContact(tempContact);
      _updateContactInMemory(tempContact);

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
        final syncedContact = apiResult.asOk.value;
        await _databaseService.updateContact(syncedContact);
        await _databaseService.updateSyncStatus(
          syncedContact.ghlId!,
          SyncStatus.synced,
        );
        await _databaseService.deleteContact(tempGhlId);
        _updateContactInMemory(syncedContact);
        return Result.ok(syncedContact);
      } else {
        _logger.error(
          'API call failed, keeping contact locally: ${apiResult.asError.error}',
        );
        return Result.ok(tempContact);
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
      _logger.info(
        'ContactRepository: Attempting to sync contact $contactId from API',
      );
      final apiResult = await _contactService.getContact(contactId);

      if (apiResult is Ok) {
        final contact = apiResult.asOk.value;
        await _databaseService.insertContact(contact);
        _updateContactInMemory(contact);
        _logger.info(
          'ContactRepository: Successfully synced contact $contactId from API',
        );
        return Result.ok(contact);
      } else {
        _logger.warning(
          'ContactRepository: Failed to sync contact $contactId from API: ${apiResult.asError.error}',
        );

        // Only return local data if API fails - no fallback behavior
        final localContact = await _databaseService.getContact(contactId);
        if (localContact != null) {
          _logger.info('ContactRepository: Returning local contact $contactId');
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
          _logger.info(
            'ContactRepository: Returning local contact $contactId after exception',
          );
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

      final locationResult = await _validateLocationAccess(
        currentContact.locationId!,
      );
      if (locationResult is Error) {
        return Result.error(locationResult.asError.error);
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
        final locationResult = await _validateLocationAccess(
          currentContact.locationId!,
        );
        if (locationResult is Error) {
          return Result.error(locationResult.asError.error);
        }

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
      _logger.info('ContactRepository: Attempting to search contacts in API');
      final locationResult = await _getCurrentLocationId();

      if (locationResult is Ok) {
        final apiResult = await _contactService.searchContacts(query);

        if (apiResult is Ok) {
          final apiResponse = apiResult.asOk.value;
          _logger.info(
            'ContactRepository: Successfully searched contacts in API, found ${apiResponse.contacts.length} results',
          );

          // Update local database with API results
          for (final contact in apiResponse.contacts) {
            try {
              await _databaseService.insertContact(contact);
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
      } else {
        _logger.warning(
          'ContactRepository: Location ID not available: ${locationResult.asError.error}',
        );
      }

      // Only search locally if API fails - no fallback behavior
      _logger.info('ContactRepository: Searching contacts locally');
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
      _logger.info('ContactRepository: Attempting advanced search in API');
      final locationResult = await _getCurrentLocationId();

      if (locationResult is Error) {
        _logger.warning(
          'ContactRepository: Location ID not available: ${locationResult.asError.error}',
        );
        return Result.error(locationResult.asError.error);
      }

      final apiResult = await _contactService.advancedSearch(
        locationId: locationResult.asOk.value,
        pageLimit: pageLimit,
        page: page,
        query: query,
        filters: filters,
        sort: sort,
      );

      if (apiResult is Ok) {
        final response = apiResult.asOk.value;
        _logger.info(
          'ContactRepository: Successfully performed advanced search in API, found ${response.contacts.length} results',
        );

        // Save API results to local database
        for (final contact in response.contacts) {
          await _databaseService.insertContact(contact);
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
    try {
      // Check if location ID is available
      final locationId = _locationService.currentLocationId;

      if (locationId == null || locationId.isEmpty) {
        _logger.error('Location ID not available for API sync');
        return Result.error(Exception('Location ID not available'));
      }

      final apiResult = await _contactService.getContacts();

      if (apiResult is Ok) {
        final apiContacts = apiResult.asOk.value.contacts;

        for (final contact in apiContacts) {
          await _databaseService.insertContact(contact);
        }
        _contacts = apiContacts;
        notifyListeners();
        return Result.ok(null);
      } else {
        final error = apiResult.asError.error;
        _logger.error(
          'API sync error: $error',
          error,
        );

        // Check if this is an authentication error
        if (error.toString().contains('Authentication required') ||
            error.toString().contains('401')) {
          // Don't return an error for auth failures - just skip sync
          return Result.ok(null);
        }

        return Result.error(
          Exception(
            'Failed to sync contacts from API',
          ),
        );
      }
    } catch (e) {
      _logger.error('Error syncing contacts from API: $e', e);
      return Result.error(
        Exception('Error syncing contacts from database'),
      );
    }
  }

  Future<void> _syncContactWithApi(ContactModel contact) async {
    try {
      _logger.info('Starting sync for contact: ${contact.ghlId}');

      final isNewContact =
          contact.ghlId == null || contact.ghlId!.startsWith('temp');

      _logger.info('Is new contact: $isNewContact');

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
        _logger.info('Successfully synced contact: ${syncedContact.ghlId}');
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
