import '../domain/repository/contact_repository.dart';
import '../model/contacts/contact_model.dart';
import '../service/auth_persistence_service.dart';
import '../service/http_service.dart';
import '../utils/logger/app_logger.dart';
import '../utils/result/result.dart';

class ContactLoadingService {
  final IContactRepository _contactRepository;
  final HttpService _httpService;
  final AuthPersistenceService _authPersistenceService;
  final AppLogger _logger;

  ContactLoadingService({
    required IContactRepository contactRepository,
    required HttpService httpService,
    required AuthPersistenceService authPersistenceService,
    required AppLogger logger,
  }) : _contactRepository = contactRepository,
       _httpService = httpService,
       _authPersistenceService = authPersistenceService,
       _logger = logger;

  /// Load contacts using the same offline-first approach as repository
  Future<List<ContactModel>> loadContacts() async {
    try {
      // Ensure authentication token is initialized before making API calls
      await _ensureAuthTokenInitialized();

      // Use the same approach as ContactRepositoryImpl - offline-first
      final result = await _contactRepository.getContacts();

      if (result is Ok) {
        final response = result.asOk.value;
        final contacts = response.contacts;

        // Debug log to check contact IDs
        _logger.info(
          'ContactLoadingService: Loaded ${contacts.length} contacts',
        );
        for (int i = 0; i < contacts.length && i < 3; i++) {
          final contact = contacts[i];
          _logger.info(
            'ContactLoadingService: Contact $i - Name: ${contact.name}, ID: ${contact.id}, GHL ID: ${contact.ghlId}',
          );
        }

        return contacts;
      } else {
        // Log the error for debugging
        _logger.warning(
          'ContactLoadingService: Failed to load contacts from repository: ${result.asError.error}',
        );
        return [];
      }
    } catch (e) {
      // Log the error for debugging
      _logger.error('ContactLoadingService: Error loading contacts: $e');
      // Se houver qualquer erro, retorna lista vazia
      return [];
    }
  }

  /// Ensures the authentication token is properly initialized before API calls
  Future<void> _ensureAuthTokenInitialized() async {
    try {
      // Check if token is already in memory
      if (_httpService.ghlToken != null && _httpService.ghlToken!.isNotEmpty) {
        return;
      }

      // Check if user is authenticated
      final isAuthenticated = await _authPersistenceService
          .isUserAuthenticated();
      if (!isAuthenticated) {
        return;
      }

      // Initialize token from persistence
      await _httpService.initializeAuthToken();
    } catch (e) {
      _logger.error('ContactLoadingService: Error initializing auth token: $e');
    }
  }
}
