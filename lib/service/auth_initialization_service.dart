import '../config/dependency_injection.dart';
import '../service/auth_persistence_service.dart';
import '../service/http_service.dart';
import '../service/sync_service.dart';
import '../utils/result/result.dart';
import '../viewmodel/user/user_viewmodel.dart';

class AuthInitializationService {
  final AuthPersistenceService _authPersistenceService;
  final UserViewModel _userViewModel;
  final HttpService _httpService;

  AuthInitializationService({
    required AuthPersistenceService authPersistenceService,
    required UserViewModel userViewModel,
    required HttpService httpService,
  }) : _authPersistenceService = authPersistenceService,
       _userViewModel = userViewModel,
       _httpService = httpService;

  /// Check authentication and fetch user data
  Future<void> checkAuthAndFetchUser() async {
    // Check if we have a valid token
    final token = await _authPersistenceService.getSanctumToken();
    if (token != null) {
      // Token exists, fetch user data
      await _userViewModel.fetchUser();
    } else {
      // No token, wait a bit and try again (in case OAuth just completed)
      await Future.delayed(const Duration(milliseconds: 1000));
      final retryToken = await _authPersistenceService.getSanctumToken();
      if (retryToken != null) {
        await _userViewModel.fetchUser();
      }
    }
  }

  /// Initialize user data when app starts (called from app initialization)
  Future<void> initializeUserData() async {
    // Ensure HTTP service has the token initialized
    await _httpService.initializeAuthToken();

    // Check if user is authenticated and has a valid token
    final isAuthenticated = await _authPersistenceService.isUserAuthenticated();

    if (isAuthenticated) {
      final token = await _authPersistenceService.getSanctumToken();

      if (token != null) {
        // Fetch user data immediately
        await _userViewModel.fetchUser();

        // Trigger smart sync to pull data from API if local storage is empty
        try {
          final syncService = getIt<SyncService>();
          final syncResult = await syncService.smartSync();
          if (syncResult is Ok) {
            // Sync successful
          } else {
            // Sync failed, but don't fail initialization
          }
        } catch (e) {
          // Error during sync, but don't fail initialization
        }
      }
    }
  }
}
