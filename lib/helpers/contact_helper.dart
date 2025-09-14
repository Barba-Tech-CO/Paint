import '../../config/dependency_injection.dart';
import '../../domain/repository/contact_repository.dart';
import '../../model/contacts/contact_model.dart';
import '../../service/auth_persistence_service.dart';
import '../../service/contact_database_service.dart';
import '../../service/contact_service.dart';
import '../../service/http_service.dart';
import '../../utils/logger/app_logger.dart';
import '../../utils/result/result.dart';

class ContactHelper {
  /// Carrega contatos usando a mesma abordagem offline-first do repositório
  static Future<List<ContactModel>> loadContacts({
    required ContactService contactService,
    required ContactDatabaseService contactDatabaseService,
  }) async {
    try {
      // Ensure authentication token is initialized before making API calls
      await _ensureAuthTokenInitialized();

      // Use the same approach as ContactRepositoryImpl - offline-first
      final contactRepository = getIt<IContactRepository>();
      final result = await contactRepository.getContacts();

      if (result is Ok) {
        final response = result.asOk.value;
        return response.contacts;
      } else {
        // Log the error for debugging
        final logger = getIt<AppLogger>();
        logger.warning('ContactHelper: Failed to load contacts from repository: ${result.asError.error}');
        return [];
      }
    } catch (e) {
      // Log the error for debugging
      final logger = getIt<AppLogger>();
      logger.error('ContactHelper: Error loading contacts: $e');
      // Se houver qualquer erro, retorna lista vazia
      return [];
    }
  }

  /// Ensures the authentication token is properly initialized before API calls
  static Future<void> _ensureAuthTokenInitialized() async {
    try {
      final httpService = getIt<HttpService>();
      final authPersistenceService = getIt<AuthPersistenceService>();

      // Check if token is already in memory
      if (httpService.ghlToken != null && httpService.ghlToken!.isNotEmpty) {
        return;
      }

      // Check if user is authenticated
      final isAuthenticated = await authPersistenceService.isUserAuthenticated();
      if (!isAuthenticated) {
        return;
      }

      // Initialize token from persistence
      await httpService.initializeAuthToken();
    } catch (e) {
      final logger = getIt<AppLogger>();
      logger.error('ContactHelper: Error initializing auth token: $e');
    }
  }
}
