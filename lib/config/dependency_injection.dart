import 'package:get_it/get_it.dart';

// Data Layer
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/contact_repository_impl.dart';
import '../data/repository/estimate_repository_impl.dart';
import '../data/repository/paint_catalog_repository_impl.dart';

// Domain Layer
import '../domain/repository/auth_repository.dart';
import '../domain/repository/contact_repository.dart';
import '../domain/repository/estimate_repository.dart';
import '../domain/repository/paint_catalog_repository.dart';

// Service Layer
import '../service/app_initialization_service.dart';
import '../features/auth/infrastructure/services/auth_service_impl.dart';
import '../service/contact_service.dart';
import '../service/deep_link_service.dart';
import '../service/estimate_service.dart';
import '../service/http_service.dart';
import '../service/navigation_service.dart';
import '../service/paint_catalog_service.dart';

// Use Case Layer
import '../features/auth/domain/usecases/auth_operations_usecase.dart';
import '../features/auth/domain/usecases/manage_auth_state_usecase.dart';
import '../features/auth/domain/usecases/handle_deep_link_usecase.dart';
import '../features/auth/domain/usecases/handle_webview_navigation_usecase.dart';
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

// ViewModel Layer
import '../features/auth/presentation/viewmodels/auth_viewmodel.dart';
import '../viewmodel/select_colors_viewmodel.dart';
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
  getIt.registerLazySingleton<EstimateService>(
    () => EstimateService(getIt<HttpService>()),
  );
  getIt.registerLazySingleton<PaintCatalogService>(
    () => PaintCatalogService(getIt<HttpService>()),
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
  getIt.registerLazySingleton<IEstimateRepository>(
    () => EstimateRepository(estimateService: getIt<EstimateService>()),
  );
  getIt.registerLazySingleton<IPaintCatalogRepository>(
    () => PaintCatalogRepository(
      paintCatalogService: getIt<PaintCatalogService>(),
    ),
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

  // ViewModels - Estimate
  getIt.registerFactory<EstimateListViewModel>(
    () => EstimateListViewModel(getIt<IEstimateRepository>()),
  );
  getIt.registerFactory<EstimateDetailViewModel>(
    () => EstimateDetailViewModel(getIt<IEstimateRepository>()),
  );
  getIt.registerFactory<EstimateUploadViewModel>(
    () => EstimateUploadViewModel(getIt<IEstimateRepository>()),
  );
  getIt.registerFactory<EstimateCalculationViewModel>(
    () => EstimateCalculationViewModel(getIt<IEstimateRepository>()),
  );

  // ViewModels - Paint Catalog
  getIt.registerFactory<PaintCatalogListViewModel>(
    () => PaintCatalogListViewModel(getIt<IPaintCatalogRepository>()),
  );
  getIt.registerFactory<PaintCatalogDetailViewModel>(
    () => PaintCatalogDetailViewModel(getIt<IPaintCatalogRepository>()),
  );

  // ViewModels - Navigation
  getIt.registerFactory<NavigationViewModel>(
    () => NavigationViewModel(),
  );

  // ViewModels - Measurements
  getIt.registerFactory<MeasurementsViewModel>(
    () => MeasurementsViewModel(),
  );

  // ViewModels - Zones (Refactored)
  getIt.registerLazySingleton<ZonesListViewModel>(
    () => ZonesListViewModel(),
  );

  getIt.registerLazySingleton<ZoneDetailViewModel>(
    () => ZoneDetailViewModel(),
  );

  getIt.registerLazySingleton<ZonesSummaryViewModel>(
    () => ZonesSummaryViewModel(),
  );

  // ViewModels - Zones (Legacy - keeping for backward compatibility)
  getIt.registerLazySingleton<ZonesCardViewmodel>(
    () => ZonesCardViewmodel(),
  );

  // ViewModels - Select Colors
  getIt.registerFactory<SelectColorsViewModel>(
    () => SelectColorsViewModel(),
  );
}
