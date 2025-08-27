import '../../domain/repository/contact_repository.dart';
import '../../model/models.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactSyncUseCase {
  final IContactRepository _contactRepository;
  final AppLogger _logger;

  ContactSyncUseCase(this._contactRepository, this._logger);

  /// Sincroniza todos os contatos pendentes com a API
  Future<Result<void>> syncAllPendingContacts() async {
    try {
      _logger.info('Starting sync of all pending contacts');

      final result = await _contactRepository.syncPendingContacts();

      if (result is Ok) {
        _logger.info('Successfully synced all pending contacts');
      } else {
        _logger.warning(
          'Some contacts failed to sync: ${result.asError.error}',
        );
      }

      return result;
    } catch (e) {
      _logger.error('Error in syncAllPendingContacts use case: $e', e);
      return Result.error(Exception('Failed to sync pending contacts: $e'));
    }
  }

  /// Obtém contatos por status de sincronização
  Future<Result<List<ContactModel>>> getContactsBySyncStatus(
    SyncStatus status,
  ) async {
    try {
      final result = await _contactRepository.getContactsBySyncStatus(
        status.name,
      );

      if (result is Ok) {
        _logger.info(
          'Retrieved ${result.asOk.value.length} contacts with status: ${status.name}',
        );
      }

      return result;
    } catch (e) {
      _logger.error('Error in getContactsBySyncStatus use case: $e', e);
      return Result.error(
        Exception('Failed to get contacts by sync status: $e'),
      );
    }
  }

  /// Obtém contatos com erro de sincronização
  Future<Result<List<ContactModel>>> getContactsWithSyncErrors() async {
    try {
      return await getContactsBySyncStatus(SyncStatus.error);
    } catch (e) {
      _logger.error('Error in getContactsWithSyncErrors use case: $e', e);
      return Result.error(
        Exception('Failed to get contacts with sync errors: $e'),
      );
    }
  }

  /// Obtém contatos pendentes de sincronização
  Future<Result<List<ContactModel>>> getPendingContacts() async {
    try {
      return await getContactsBySyncStatus(SyncStatus.pending);
    } catch (e) {
      _logger.error('Error in getPendingContacts use case: $e', e);
      return Result.error(Exception('Failed to get pending contacts: $e'));
    }
  }

  /// Obtém contatos já sincronizados
  Future<Result<List<ContactModel>>> getSyncedContacts() async {
    try {
      return await getContactsBySyncStatus(SyncStatus.synced);
    } catch (e) {
      _logger.error('Error in getSyncedContacts use case: $e', e);
      return Result.error(Exception('Failed to get synced contacts: $e'));
    }
  }

  /// Força uma nova tentativa de sincronização para contatos com erro
  Future<Result<void>> retryFailedSyncs() async {
    try {
      _logger.info('Retrying failed syncs for contacts with errors');

      // Get contacts with sync errors
      final errorContactsResult = await getContactsWithSyncErrors();
      if (errorContactsResult is Error) {
        return errorContactsResult;
      }

      final errorContacts = errorContactsResult.asOk.value;
      if (errorContacts.isEmpty) {
        _logger.info('No contacts with sync errors found');
        return Result.ok(null);
      }

      _logger.info(
        'Found ${errorContacts.length} contacts with sync errors, retrying sync',
      );

      // Attempt to sync all contacts with errors
      final syncResult = await _contactRepository.syncPendingContacts();

      if (syncResult is Ok) {
        _logger.info('Successfully retried sync for contacts with errors');
      } else {
        _logger.warning(
          'Some retry attempts failed: ${syncResult.asError.error}',
        );
      }

      return syncResult;
    } catch (e) {
      _logger.error('Error in retryFailedSyncs use case: $e', e);
      return Result.error(Exception('Failed to retry failed syncs: $e'));
    }
  }
}
