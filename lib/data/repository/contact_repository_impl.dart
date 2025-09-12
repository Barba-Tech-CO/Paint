import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_list_response.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/auth_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../service/location_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactRepository implements IContactRepository {
  final ContactService _contactService;
  final ContactDatabaseService _databaseService;
  final AuthService _authService;
  final LocationService _locationService;
  final AppLogger _logger;

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
       _logger = logger;

  @override
  Future<Result<ContactListResponse>> getContacts({
    int? limit,
    int? offset,
  }) async {
    try {
      // Always return data from local database first (offline-first)
      final localContacts = await _databaseService.getAllContacts(
        limit: limit,
        offset: offset,
      );

      final totalCount = await _databaseService.getContactsCount();

      final response = ContactListResponse(
        contacts: localContacts,
        count: localContacts.length,
        total: totalCount,
        limit: limit,
        offset: offset,
      );

      // Attempt to sync with API in background and handle errors
      final syncResult = await _syncWithApiInBackground();
      if (syncResult is Error) {
        // Log sync error to console
        _logger.error(
          'Background sync failed: ${syncResult.asError.error}',
          syncResult.asError.error,
        );
        // Return contacts from local database but with sync error info
        // The error will be available for the UI to show to the user
        return Result.ok(response);
      }

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
      // Try to get from local database first
      final localContact = await _databaseService.getContact(contactId);

      if (localContact != null) {
        // Attempt to sync with API in the background
        try {
          await _syncContactWithApiInBackground(contactId);
        } catch (e) {
          // Log sync error but don't fail the get operation
          _logger.error('Background sync failed for contact $contactId: $e', e);
        }
        return Result.ok(localContact);
      }

      // If not found locally, try API
      final apiResult = await _contactService.getContact(contactId);
      if (apiResult is Ok) {
        final contact = apiResult.asOk.value;
        // Save to local database
        await _databaseService.insertContact(contact);
        return Result.ok(contact);
      } else {
        return apiResult;
      }
    } catch (e) {
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
      // Get current contact from local database
      final currentContact = await _databaseService.getContact(contactId);
      if (currentContact == null) {
        return Result.error(Exception('Contact not found'));
      }

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

      // Attempt to sync with API
      final apiResult = await _contactService.updateContact(
        contactId,
        name: name,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
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
        return Result.ok(syncedContact);
      } else {
        // Keep the contact as pending for later sync
        return Result.ok(updatedContact);
      }
    } catch (e) {
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
        return Result.ok(true);
      } else {
        // Keep in local database for later sync
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

  Future<void> _syncContactWithApiInBackground(String contactId) async {
    try {
      final contact = await _databaseService.getContact(contactId);
      if (contact != null) {
        await _syncContactWithApi(contact);
      }
    } catch (e) {
      // Log error but don't throw - in production, use proper logging service
      _logger.error('Background contact sync error: $e', e);
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
