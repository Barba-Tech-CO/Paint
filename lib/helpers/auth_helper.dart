import '../config/dependency_injection.dart';
import '../service/auth_persistence_service.dart';
import '../service/http_service.dart';
import '../viewmodel/user/user_viewmodel.dart';

class AuthHelper {
  static Future<void> checkAuthAndFetchUser() async {
    final authPersistenceService = getIt<AuthPersistenceService>();
    final userViewModel = getIt<UserViewModel>();

    // Check if we have a valid token
    final token = await authPersistenceService.getSanctumToken();
    if (token != null) {
      // Token exists, fetch user data
      await userViewModel.fetchUser();
    } else {
      // No token, wait a bit and try again (in case OAuth just completed)
      await Future.delayed(const Duration(milliseconds: 1000));
      final retryToken = await authPersistenceService.getSanctumToken();
      if (retryToken != null) {
        await userViewModel.fetchUser();
      }
    }
  }

  /// Initialize user data when app starts (called from app initialization)
  static Future<void> initializeUserData() async {
    final authPersistenceService = getIt<AuthPersistenceService>();
    final httpService = getIt<HttpService>();
    final userViewModel = getIt<UserViewModel>();

    // Ensure HTTP service has the token initialized
    await httpService.initializeAuthToken();

    // Check if user is authenticated and has a valid token
    final isAuthenticated = await authPersistenceService.isUserAuthenticated();
    if (isAuthenticated) {
      final token = await authPersistenceService.getSanctumToken();
      if (token != null) {
        // Fetch user data immediately
        await userViewModel.fetchUser();
      }
    }
  }
}
