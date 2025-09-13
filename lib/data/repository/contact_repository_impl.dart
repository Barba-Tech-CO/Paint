import 'dart:async';

import '../../domain/repository/contact_repository.dart';
import '../../helpers/error_message_helper.dart';
import '../../model/contacts/contact_list_response.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/auth_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../service/location_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactRepository extends IContactRepository {
  final ContactService _contactService;
  final ContactDatabaseService _databaseService;
  final AuthService _authService;
  final LocationService _locationService;
  final AppLogger _logger;

  // Source of truth - internal state
  List<ContactModel> _contacts = [];

  // Initialization control
  Completer<void>? _initializationCompleter;

  @override
  List<ContactModel> get contacts => List.unmodifiable(_contacts);

  @override
  int get contactsCount => _contacts.length;

  ContactRepository({
    required ContactService contactService,
    required ContactDatabaseService databaseService,
    required AuthService authService,
    required LocationService locationService,
    required AppLogger logger,
  }) : _contactService = contactService,
       _databaseService = databaseService,
       _authService = authService,
       _locationService = locationService,
       _logger = logger {
    // Initialize contacts from database
    _initializationCompleter = Completer<void>();
    _initializeFromDatabase();
  }

  /// Initialize contacts from local database
  Future<void> _initializeFromDatabase() async {
    try {
      final localContacts = await _databaseService.getAllContacts();
      _contacts = localContacts;
      // Sync in background without blocking initialization
      _syncWithApiInBackground();
    } catch (e) {
      _logger.error('Failed to initialize contacts from database: $e', e);
      _contacts = [];
    } finally {
      // Mark initialization as complete
      _initializationCompleter?.complete();
      _initializationCompleter = null;
    }
  }

  @override
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      // Wait for initialization to complete if it's still running
      if (_initializationCompleter != null) {
        await _initializationCompleter!.future;
      }

      // Return current state immediately (source of truth)
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

      // Attempt to sync with API in background (non-blocking)
      _syncWithApiInBackground();

      return Result.ok(response);
    } catch (e) {
      return Result.error(
        Exception('Error getting contacts: $e'),
      );
    }
  }

  @override
  /// Cria um novo contato
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
      // Get the current location_id from location service
      final locationId = _locationService.currentLocationId;
      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      // Create a temporary contact with pending sync status
      final tempGhlId =
          'temp_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecond}';

      final tempContact = ContactModel(
        ghlId: tempGhlId,
        locationId: locationId, // Use actual location_id from auth
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save to local database immediately
      await _databaseService.insertContact(tempContact);

      // Update internal state and notify listeners
      _contacts.add(tempContact);
      notifyListeners();

      // Attempt to sync with API
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
        // Update local database with synced data
        await _databaseService.updateContact(syncedContact);
        await _databaseService.updateSyncStatus(
          syncedContact.ghlId!,
          SyncStatus.synced,
        );
        // Remove the temporary contact
        await _databaseService.deleteContact(tempGhlId);

        // Update internal state with synced contact
        final tempIndex = _contacts.indexWhere((c) => c.ghlId == tempGhlId);
        if (tempIndex != -1) {
          _contacts[tempIndex] = syncedContact;
          notifyListeners();
        }

        return Result.ok(syncedContact);
      } else {
        // API call failed, but contact is saved locally
        // Log the error for debugging
        _logger.info(
          'API call failed, keeping contact locally: ${apiResult.asError.error}',
        );

        // Keep the contact as pending for later sync
        // Return success since the contact was saved locally
        return Result.ok(tempContact);
      }
    } catch (e) {
      return Result.error(
        Exception('Error creating contact: $e'),
      );
    }
  }

  @override
  Future<Result<ContactModel>> getContact(String contactId) async {
    try {
      // Always try API first to get the most up-to-date data
      final apiResult = await _contactService.getContact(contactId);

      if (apiResult is Ok) {
        final contact = apiResult.asOk.value;
        // Save to local database
        await _databaseService.insertContact(contact);

        // Update in memory if exists
        final contactIndex = _contacts.indexWhere((c) => c.ghlId == contactId);
        if (contactIndex != -1) {
          _contacts[contactIndex] = contact;
          notifyListeners();
        }

        return Result.ok(contact);
      } else {
        // If API fails, try local database as fallback
        final localContact = await _databaseService.getContact(contactId);
        if (localContact != null) {
          return Result.ok(localContact);
        }
        return apiResult;
      }
    } catch (e) {
      // If API fails, try local database as fallback
      try {
        final localContact = await _databaseService.getContact(contactId);
        if (localContact != null) {
          return Result.ok(localContact);
        }
      } catch (localError) {
        _logger.error('Local database error: $localError', localError);
      }

      return Result.error(
        Exception('Error getting contact: $e'),
      );
    }
  }

  @override
  /// Atualiza um contato
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
      // Log user action for error tracking
      ErrorMessageHelper.logUserAction(
        'Update Contact - Repository',
        {
          'contactId': contactId,
          'hasName': name != null,
          'hasEmail': email != null,
          'hasPhone': phone != null,
        },
      );

      // Get current contact from local database
      final currentContact = await _databaseService.getContact(contactId);
      if (currentContact == null) {
        _logger.error('Contact not found in database', contactId);
        return Result.error(Exception('Contact not found'));
      }

      // Verify location_id matches current user's location
      final locationIdResult = await _authService.getCurrentLocationId();
      if (locationIdResult is Error) {
        _logger.error(
          'Failed to get location ID',
          locationIdResult.asError.error,
        );
        return Result.error(
          Exception(
            'Error getting location_id: ${locationIdResult.asError.error}',
          ),
        );
      }

      final currentLocationId = locationIdResult.asOk.value;
      if (currentLocationId == null || currentLocationId.isEmpty) {
        _logger.error('Location ID is null or empty');
        return Result.error(
          Exception('Location ID not available. User not authenticated.'),
        );
      }

      if (currentContact.locationId != currentLocationId) {
        _logger.error('Contact location mismatch', {
          'contactLocationId': currentContact.locationId,
          'currentLocationId': currentLocationId,
        });
        return Result.error(
          Exception('Contact does not belong to current user location.'),
        );
      }

      // Create updated contact with pending sync status
      final updatedContact = currentContact.copyWith(
        name: name,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
        customFields: customFields,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      );

      // Update local database immediately
      await _databaseService.updateContact(updatedContact);

      // Update internal state and notify listeners
      final contactIndex = _contacts.indexWhere((c) => c.ghlId == contactId);
      if (contactIndex != -1) {
        _contacts[contactIndex] = updatedContact;
        notifyListeners();
      }

      // Attempt to sync with API
      final apiResult = await _contactService.updateContact(
        contactId,
        name: name,
        email: email,
        phone: phone,
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

        // Preserve the locationId and other fields from the current contact
        // since API doesn't return them correctly in the response
        final contactWithPreservedData = syncedContact.copyWith(
          locationId: currentContact.locationId,
          // Preserve the name we sent if API returns null
          name: (syncedContact.name.isEmpty || syncedContact.name == 'null')
              ? updatedContact.name
              : syncedContact.name,
          // Preserve the address we sent if API returns null
          address:
              (syncedContact.address.isEmpty || syncedContact.address == 'null')
              ? updatedContact.address
              : syncedContact.address,
          // Preserve other fields that might be null in API response
          city: (syncedContact.city.isEmpty || syncedContact.city == 'null')
              ? updatedContact.city
              : syncedContact.city,
          state: (syncedContact.state.isEmpty || syncedContact.state == 'null')
              ? updatedContact.state
              : syncedContact.state,
          postalCode:
              (syncedContact.postalCode.isEmpty ||
                  syncedContact.postalCode == 'null')
              ? updatedContact.postalCode
              : syncedContact.postalCode,
        );

        // Log data preservation for debugging
        _logger.info('📋 Data preservation after API sync:', {
          'original_name': syncedContact.name,
          'preserved_name': contactWithPreservedData.name,
          'original_address': syncedContact.address,
          'preserved_address': contactWithPreservedData.address,
          'original_city': syncedContact.city,
          'preserved_city': contactWithPreservedData.city,
          'original_state': syncedContact.state,
          'preserved_state': contactWithPreservedData.state,
          'original_postalCode': syncedContact.postalCode,
          'preserved_postalCode': contactWithPreservedData.postalCode,
          'locationId_preserved': contactWithPreservedData.locationId,
        });

        // Update local database with synced data (preserving important fields)
        await _databaseService.updateContact(contactWithPreservedData);
        await _databaseService.updateSyncStatus(
          contactWithPreservedData.ghlId!,
          SyncStatus.synced,
        );

        // Update internal state with synced contact
        if (contactIndex != -1) {
          _contacts[contactIndex] = contactWithPreservedData;
          notifyListeners();
        }

        return Result.ok(contactWithPreservedData);
      } else {
        // Keep the contact as pending for later sync
        _logger.info(
          'API sync failed, keeping contact as pending: ${apiResult.asError.error}',
        );
        return Result.ok(updatedContact);
      }
    } catch (e) {
      _logger.error('Error updating contact', e);
      return Result.error(
        Exception('Error updating contact: $e'),
      );
    }
  }

  @override
  /// Remove um contato
  Future<Result<bool>> deleteContact(String contactId) async {
    try {
      // Get current contact from local database
      final currentContact = await _databaseService.getContact(contactId);
      if (currentContact != null) {
        // Verify location_id matches current user's location
        final locationIdResult = await _authService.getCurrentLocationId();
        if (locationIdResult is Error) {
          return Result.error(
            Exception(
              'Error getting location_id: ${locationIdResult.asError.error}',
            ),
          );
        }

        final currentLocationId = locationIdResult.asOk.value;
        if (currentLocationId == null || currentLocationId.isEmpty) {
          return Result.error(
            Exception('Location ID not available. User not authenticated.'),
          );
        }

        if (currentContact.locationId != currentLocationId) {
          return Result.error(
            Exception('Contact does not belong to current user location.'),
          );
        }

        // Mark as deleted in local database immediately
        await _databaseService.updateSyncStatus(
          contactId,
          SyncStatus.pending,
        );
      }

      // Attempt to delete from API
      final apiResult = await _contactService.deleteContact(contactId);
      if (apiResult is Ok) {
        // Remove from local database on successful API deletion
        await _databaseService.deleteContact(contactId);

        // Update internal state and notify listeners
        _contacts.removeWhere((c) => c.ghlId == contactId);
        notifyListeners();

        return Result.ok(true);
      } else {
        // Keep in local database for later sync but don't show to user
        // Update internal state to remove from UI
        _contacts.removeWhere((c) => c.ghlId == contactId);
        notifyListeners();

        return Result.ok(true);
      }
    } catch (e) {
      return Result.error(
        Exception('Error deleting contact: $e'),
      );
    }
  }

  @override
  Future<Result<ContactListResponse>> searchContacts(String query) async {
    try {
      // Search in local database first
      final localContacts = await _databaseService.searchContacts(query);

      final response = ContactListResponse(
        contacts: localContacts,
        count: localContacts.length,
        total: localContacts.length,
      );

      // Attempt to sync with API in the background
      try {
        await _syncWithApiInBackground();
      } catch (e) {
        // Log sync error but don't fail the search operation
        _logger.error('Background sync failed during search: $e', e);
      }

      return Result.ok(response);
    } catch (e) {
      return Result.error(
        Exception('Error searching contacts: $e'),
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
      // Get the current location_id from location service
      final locationId = _locationService.currentLocationId;

      if (locationId == null || locationId.isEmpty) {
        return Result.error(
          Exception('Location ID not available. Please authenticate first.'),
        );
      }

      // For advanced search, we'll use the API directly
      // but cache results locally
      final apiResult = await _contactService.advancedSearch(
        locationId: locationId,
        pageLimit: pageLimit,
        page: page,
        query: query,
        filters: filters,
        sort: sort,
      );

      if (apiResult is Ok) {
        final response = apiResult.asOk.value;

        // Cache contacts locally
        for (final contact in response.contacts) {
          await _databaseService.insertContact(contact);
        }

        return Result.ok(response);
      } else {
        return apiResult;
      }
    } catch (e) {
      return Result.error(
        Exception('Error in advanced search: $e'),
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
          // Log individual contact sync error but continue with others
          _logger.error('Failed to sync contact ${contact.ghlId}: $e', e);
        }
      }

      return Result.ok(null);
    } catch (e) {
      return Result.error(
        Exception('Error syncing contacts: $e'),
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
      return Result.error(
        Exception('Error getting contacts by status: $e'),
      );
    }
  }

  // Private helper methods
  Future<Result<void>> _syncWithApiInBackground() async {
    // This would typically run in a background task
    try {
      // Only sync down from API (GET), don't try to create contacts (POST)
      // This prevents the 405 error when accessing the contacts screen
      return await _syncContactsFromApi();
    } catch (e) {
      // Log error to console using logger
      _logger.error('Background sync error: $e', e);
      return Result.error(
        Exception('Error syncing contacts: $e'),
      );
    }
  }

  /// Sync contacts from API to local database (GET only)
  Future<Result<void>> _syncContactsFromApi() async {
    try {
      // Get contacts from API (GET request)
      final apiResult = await _contactService.getContacts();

      if (apiResult is Ok) {
        final apiContacts = apiResult.asOk.value.contacts;

        // Update local database with API data
        for (final contact in apiContacts) {
          await _databaseService.insertContact(contact);
        }

        // Update internal state and notify listeners
        _contacts = apiContacts;
        notifyListeners();

        return Result.ok(null);
      } else {
        // Log API error to console
        _logger.error(
          'API sync error: ${apiResult.asError.error}',
          apiResult.asError.error,
        );
        return Result.error(
          Exception(
            'Failed to sync contacts from API: ${apiResult.asError.error}',
          ),
        );
      }
    } catch (e) {
      // Log error to console
      _logger.error('Error syncing contacts from API: $e', e);
      return Result.error(
        Exception('Error syncing contacts from API: $e'),
      );
    }
  }

  Future<void> _syncContactWithApi(ContactModel contact) async {
    try {
      if (contact.ghlId == null || contact.ghlId!.startsWith('temp')) {
        // This is a new contact, try to sync it
        final result = await _contactService.createContact(
          name: contact.name,
          email: contact.email,
          phone: contact.phone,
          companyName: contact.companyName,
          address: contact.address,
          customFields: contact.customFields,
        );

        if (result is Ok) {
          final syncedContact = result.asOk.value;
          await _databaseService.updateContact(syncedContact);
          await _databaseService.updateSyncStatus(
            syncedContact.ghlId!,
            SyncStatus.synced,
          );
        }
      } else {
        // This is an existing contact, try to update it
        final result = await _contactService.updateContact(
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
        }
      }
    } catch (e) {
      // Mark as error for later retry
      await _databaseService.updateSyncStatus(
        contact.ghlId ?? 'unknown',
        SyncStatus.error,
        error: e.toString(),
      );
    }
  }
}
