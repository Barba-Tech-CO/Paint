import 'package:get_it/get_it.dart';

// Data Layer
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/contact_repository_impl.dart';

// Domain Layer
import '../domain/repository/auth_repository.dart';
import '../features/contacts/domain/repositories/contact_repository.dart';

// Service Layer
import '../service/app_initialization_service.dart';
import '../features/auth/infrastructure/services/auth_service_impl.dart';
import '../service/contact_service.dart';
import '../service/deep_link_service.dart';
import '../service/http_service.dart';
import '../service/navigation_service.dart';

// Use Case Layer
import '../features/auth/domain/usecases/auth_operations_usecase.dart';
import '../features/auth/domain/usecases/manage_auth_state_usecase.dart';
import '../features/auth/domain/usecases/handle_deep_link_usecase.dart';
import '../features/auth/domain/usecases/handle_webview_navigation_usecase.dart';
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

// ViewModel Layer
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../features/select_colors/presentation/viewmodels/select_colors_viewmodel.dart';
import '../viewmodel/viewmodels.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  // Serviços
  getIt.registerLazySingleton<HttpService>(
    () => HttpService(),
  );
  getIt.registerLazySingleton<AuthService>(
    () => AuthService(getIt<HttpService>()),
  );
  getIt.registerLazySingleton<ContactService>(
    () => ContactService(getIt<HttpService>()),
  );

  getIt.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );
  getIt.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(),
  );
  getIt.registerLazySingleton<AppLogger>(
    () => LoggerAppLoggerImpl(),
  );

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(authService: getIt<AuthService>()),
  );
  getIt.registerLazySingleton<IContactRepository>(
    () => ContactRepository(contactService: getIt<ContactService>()),
  );


  // Use Cases
  getIt.registerLazySingleton<AuthOperationsUseCase>(
    () => AuthOperationsUseCase(getIt<AuthService>()),
  );
  getIt.registerLazySingleton<ManageAuthStateUseCase>(
    () => ManageAuthStateUseCase(),
  );
  getIt.registerLazySingleton<HandleDeepLinkUseCase>(
    () => HandleDeepLinkUseCase(
      getIt<AuthOperationsUseCase>(),
      getIt<ManageAuthStateUseCase>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<HandleWebViewNavigationUseCase>(
    () => HandleWebViewNavigationUseCase(),
  );

  getIt.registerLazySingleton<AppInitializationService>(
    () => AppInitializationService(
      getIt<AuthService>(),
      getIt<NavigationService>(),
      getIt<DeepLinkService>(),
    ),
  );

  // ViewModels - Auth
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(
      getIt<AuthOperationsUseCase>(),
      getIt<HandleDeepLinkUseCase>(),
      getIt<HandleWebViewNavigationUseCase>(),
      getIt<DeepLinkService>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Contact
  getIt.registerFactory<ContactListViewModel>(
    () => ContactListViewModel(getIt<IContactRepository>()),
  );
  getIt.registerFactory<ContactDetailViewModel>(
    () => ContactDetailViewModel(getIt<IContactRepository>()),
  );



  // ViewModels - Navigation
  getIt.registerFactory<NavigationViewModel>(
    () => NavigationViewModel(),
  );

  // ViewModels - Measurements
  getIt.registerFactory<MeasurementsViewModel>(
    () => MeasurementsViewModel(),
  );



  // ViewModels - Select Colors
  getIt.registerFactory<SelectColorsViewModel>(
    () => SelectColorsViewModel(),
  );
}
