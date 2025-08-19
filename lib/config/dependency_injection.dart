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
import '../service/auth_service.dart';
import '../service/contact_service.dart';
import '../service/deep_link_service.dart';
import '../service/estimate_service.dart';
import '../service/http_service.dart';
import '../service/navigation_service.dart';
import '../service/paint_catalog_service.dart';

// Use Case Layer
import '../use_case/auth/auth_use_cases.dart';
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

// ViewModel Layer
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
    () => ContactListViewModel(
      getIt<IContactRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<ContactDetailViewModel>(
    () => ContactDetailViewModel(
      getIt<IContactRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Estimate
  getIt.registerFactory<EstimateListViewModel>(
    () => EstimateListViewModel(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<EstimateDetailViewModel>(
    () => EstimateDetailViewModel(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<EstimateUploadViewModel>(
    () => EstimateUploadViewModel(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<EstimateCalculationViewModel>(
    () => EstimateCalculationViewModel(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Paint Catalog
  getIt.registerFactory<PaintCatalogListViewModel>(
    () => PaintCatalogListViewModel(
      getIt<IPaintCatalogRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerFactory<PaintCatalogDetailViewModel>(
    () => PaintCatalogDetailViewModel(
      getIt<IPaintCatalogRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Navigation
  getIt.registerFactory<NavigationViewModel>(
    () => NavigationViewModel(
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Measurements
  getIt.registerFactory<MeasurementsViewModel>(
    () => MeasurementsViewModel(
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Zones (Refactored)
  getIt.registerLazySingleton<ZonesListViewModel>(
    () => ZonesListViewModel(getIt<AppLogger>()),
  );

  getIt.registerLazySingleton<ZoneDetailViewModel>(
    () => ZoneDetailViewModel(
      getIt<AppLogger>(),
    ),
  );

  getIt.registerLazySingleton<ZonesSummaryViewModel>(
    () => ZonesSummaryViewModel(
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Zones (Legacy - keeping for backward compatibility)
  getIt.registerLazySingleton<ZonesCardViewmodel>(
    () => ZonesCardViewmodel(
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Select Colors
  getIt.registerFactory<SelectColorsViewModel>(
    () => SelectColorsViewModel(),
  );
}
