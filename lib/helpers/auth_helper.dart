import '../config/dependency_injection.dart';
import '../service/auth_persistence_service.dart';
import '../service/http_service.dart';
import '../service/location_service.dart';
import '../viewmodel/user/user_viewmodel.dart';

class AuthHelper {
  static Future<void> checkAuthAndFetchUser() async {
    final authPersistenceService = getIt<AuthPersistenceService>();
    final locationService = getIt<LocationService>();
    final userViewModel = getIt<UserViewModel>();

    // Check if we have a valid token
    final token = await authPersistenceService.getSanctumToken();
    if (token != null) {
      // Load location ID from persistence and set it in LocationService
      final authState = await authPersistenceService.loadAuthState();
      final locationId = authState['locationId'] as String?;
      if (locationId != null && locationId.isNotEmpty) {
        locationService.setLocationId(locationId);
      }

      // Token exists, fetch user data
      await userViewModel.fetchUser();
    } else {
      // No token, wait a bit and try again (in case OAuth just completed)
      await Future.delayed(const Duration(milliseconds: 1000));
      final retryToken = await authPersistenceService.getSanctumToken();
      if (retryToken != null) {
        // Load location ID from persistence and set it in LocationService
        final authState = await authPersistenceService.loadAuthState();
        final locationId = authState['locationId'] as String?;
        if (locationId != null && locationId.isNotEmpty) {
          locationService.setLocationId(locationId);
        }

        await userViewModel.fetchUser();
      }
    }
  }

  /// Initialize user data when app starts (called from app initialization)
  static Future<void> initializeUserData() async {
    final authPersistenceService = getIt<AuthPersistenceService>();
    final httpService = getIt<HttpService>();
    final locationService = getIt<LocationService>();
    final userViewModel = getIt<UserViewModel>();

    // Ensure HTTP service has the token initialized
    await httpService.initializeAuthToken();

    // Check if user is authenticated and has a valid token
    final isAuthenticated = await authPersistenceService.isUserAuthenticated();

    if (isAuthenticated) {
      final token = await authPersistenceService.getSanctumToken();

      if (token != null) {
        // Load location ID from persistence and set it in LocationService
        final authState = await authPersistenceService.loadAuthState();
        final locationId = authState['locationId'] as String?;

        if (locationId != null && locationId.isNotEmpty) {
          locationService.setLocationId(locationId);
        }

        // Fetch user data immediately
        await userViewModel.fetchUser();
      }
    }
  }
}
