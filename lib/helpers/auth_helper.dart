import '../config/dependency_injection.dart';
import '../service/auth_persistence_service.dart';
import '../viewmodel/user/user_viewmodel.dart';

class AuthHelper {
  static Future<void> checkAuthAndFetchUser() async {
    final authPersistenceService = getIt<AuthPersistenceService>();
    final userViewModel = getIt<UserViewModel>();

    // Check if we have a valid token
    final token = await authPersistenceService.getSanctumToken();
    if (token != null) {
      // Token exists, fetch user data
      userViewModel.fetchUser();
    } else {
      // No token, wait a bit and try again (in case OAuth just completed)
      await Future.delayed(const Duration(milliseconds: 1000));
      final retryToken = await authPersistenceService.getSanctumToken();
      if (retryToken != null) {
        userViewModel.fetchUser();
      }
    }
  }
}
