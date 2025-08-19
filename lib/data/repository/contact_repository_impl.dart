import '../../domain/repository/contact_repository.dart';
import '../../model/contact_list_response.dart';
import '../../model/contact_model.dart';
import '../../service/contact_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/logger_service.dart';
import '../../service/auth_service.dart';
import '../../utils/result/result.dart';

class ContactRepository implements IContactRepository {
  final ContactService _contactService;
  final ContactDatabaseService _databaseService;
  final AuthService _authService;

  ContactRepository({
    required ContactService contactService,
    required ContactDatabaseService databaseService,
    required AuthService authService,
  }) : _contactService = contactService,
       _databaseService = databaseService,
       _authService = authService;

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

      // Attempt to sync with API in the background
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
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyName,
    String? address,
    List<Map<String, dynamic>>? customFields,
  }) async {
    try {
      // Get the current location_id from auth service
      final locationIdResult = await _authService.getCurrentLocationId();
      if (locationIdResult is Error) {
        return Result.error(
          Exception(
            'Error getting location_id: ${locationIdResult.asError.error}',
          ),
        );
      }

      final locationId = locationIdResult.asOk.value;
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
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        companyName: companyName,
        address: address,
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
        firstName: firstName,
        lastName: lastName,
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
        // Remove the temporary contact
        await _databaseService.deleteContact(tempGhlId);
        return Result.ok(syncedContact);
      } else {
        // Keep the contact as pending for later sync
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
        _syncContactWithApiInBackground(contactId);
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
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? companyName,
    String? address,
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
        firstName: firstName ?? currentContact.firstName,
        lastName: lastName ?? currentContact.lastName,
        email: email ?? currentContact.email,
        phone: phone ?? currentContact.phone,
        companyName: companyName ?? currentContact.companyName,
        address: address ?? currentContact.address,
        customFields: customFields ?? currentContact.customFields,
        syncStatus: SyncStatus.pending,
        updatedAt: DateTime.now(),
      );

      // Update local database immediately
      await _databaseService.updateContact(updatedContact);

      // Attempt to sync with API
      final apiResult = await _contactService.updateContact(
        contactId,
        name: name,
        firstName: firstName,
        lastName: lastName,
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
      _syncWithApiInBackground();

      return Result.ok(response);
    } catch (e) {
      return Result.error(
        Exception('Error searching contacts: $e'),
      );
    }
  }

  @override
  Future<Result<ContactListResponse>> advancedSearch({
    String? locationId,
    int? pageLimit,
    int? page,
    String? query,
    List<Map<String, dynamic>>? filters,
    List<Map<String, dynamic>>? sort,
  }) async {
    try {
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
        await _syncContactWithApi(contact);
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
  Future<void> _syncWithApiInBackground() async {
    // This would typically run in a background task
    try {
      await syncPendingContacts();
    } catch (e) {
      // Log error but don't throw - in production, use proper logging service
      // ignore: avoid_print
      LoggerService.error('Background sync error: $e');
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
      // ignore: avoid_print
      LoggerService.error('Background contact sync error: $e');
    }
  }

  Future<void> _syncContactWithApi(ContactModel contact) async {
    try {
      if (contact.ghlId == null || contact.ghlId!.startsWith('temp')) {
        // This is a new contact, try to create it
        final result = await _contactService.createContact(
          firstName: contact.firstName,
          lastName: contact.lastName,
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
          firstName: contact.firstName,
          lastName: contact.lastName,
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
