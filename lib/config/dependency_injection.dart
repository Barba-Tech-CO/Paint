import 'package:get_it/get_it.dart';

// Data Layer
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/contact_repository_impl.dart';
import '../data/repository/estimate_repository_impl.dart';
import '../data/repository/material_repository_impl.dart';
import '../data/repository/paint_catalog_repository_impl.dart';

// Domain Layer
import '../domain/repository/auth_repository.dart';
import '../domain/repository/contact_repository.dart';
import '../domain/repository/estimate_repository.dart';
import '../domain/repository/material_repository.dart';
import '../domain/repository/paint_catalog_repository.dart';

// Service Layer
import '../service/app_initialization_service.dart';
import '../service/auth_service.dart';
import '../service/auth_persistence_service.dart';
import '../service/contact_service.dart';
import '../service/contact_database_service.dart';
import '../service/deep_link_service.dart';
import '../service/estimate_service.dart';
import '../service/http_service.dart';
import '../service/location_service.dart';
import '../service/navigation_service.dart';
import '../service/material_service.dart';
import '../service/paint_catalog_service.dart';

// Logger Layer
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

// Use Case Layer
import '../use_case/auth/auth_use_cases.dart';

// ViewModel Layer
import '../viewmodel/select_colors_viewmodel.dart';
import '../viewmodel/viewmodels.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  // Logger Layer - Register first to avoid circular dependencies
  getIt.registerLazySingleton<AppLogger>(
    () => LoggerAppLoggerImpl(),
  );

  // Serviços
  getIt.registerLazySingleton<HttpService>(
    () {
      final httpService = HttpService();
      httpService.setLogger(
        getIt<AppLogger>(),
      );
      return httpService;
    },
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      getIt<HttpService>(),
      getIt<LocationService>(),
    ),
  );
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
  getIt.registerLazySingleton<ContactService>(
    () => ContactService(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<ContactDatabaseService>(
    () => ContactDatabaseService(),
  );
  getIt.registerLazySingleton<EstimateService>(
    () => EstimateService(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<MaterialService>(
    () => MaterialService(),
  );
  getIt.registerLazySingleton<PaintCatalogService>(
    () => PaintCatalogService(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<NavigationService>(
    () => NavigationService(),
  );
  getIt.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(),
  );
  getIt.registerLazySingleton<AuthPersistenceService>(
    () => AuthPersistenceService(),
  );

  // Repositories
  getIt.registerLazySingleton<IAuthRepository>(
    () => AuthRepository(
      authService: getIt<AuthService>(),
    ),
  );
  getIt.registerLazySingleton<IContactRepository>(
    () => ContactRepository(
      contactService: getIt<ContactService>(),
      databaseService: getIt<ContactDatabaseService>(),
      authService: getIt<AuthService>(),
      locationService: getIt<LocationService>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<IEstimateRepository>(
    () => EstimateRepository(
      estimateService: getIt<EstimateService>(),
    ),
  );
  getIt.registerLazySingleton<IMaterialRepository>(
    () => MaterialRepository(materialService: getIt<MaterialService>()),
  );
  getIt.registerLazySingleton<IPaintCatalogRepository>(
    () => PaintCatalogRepository(
      paintCatalogService: getIt<PaintCatalogService>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<AuthOperationsUseCase>(
    () => AuthOperationsUseCase(
      getIt<AuthService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<ManageAuthStateUseCase>(
    () => ManageAuthStateUseCase(),
  );
  getIt.registerLazySingleton<HandleDeepLinkUseCase>(
    () => HandleDeepLinkUseCase(
      getIt<AuthOperationsUseCase>(),
      getIt<ManageAuthStateUseCase>(),
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
      getIt<AuthPersistenceService>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Contact
  getIt.registerFactory<ContactListViewModel>(
    () => ContactListViewModel(
      getIt<IContactRepository>(),
    ),
  );
  getIt.registerFactory<ContactDetailViewModel>(
    () => ContactDetailViewModel(
      getIt<IContactRepository>(),
      getIt<LocationService>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Estimate
  getIt.registerFactory<EstimateListViewModel>(
    () => EstimateListViewModel(
      getIt<IEstimateRepository>(),
    ),
  );
  getIt.registerFactory<EstimateDetailViewModel>(
    () => EstimateDetailViewModel(
      getIt<IEstimateRepository>(),
    ),
  );
  getIt.registerFactory<EstimateUploadViewModel>(
    () => EstimateUploadViewModel(
      getIt<IEstimateRepository>(),
    ),
  );
  getIt.registerFactory<EstimateCalculationViewModel>(
    () => EstimateCalculationViewModel(
      getIt<IEstimateRepository>(),
    ),
  );

  // ViewModels - Paint Catalog
  getIt.registerFactory<PaintCatalogListViewModel>(
    () => PaintCatalogListViewModel(
      getIt<IPaintCatalogRepository>(),
    ),
  );
  getIt.registerFactory<PaintCatalogDetailViewModel>(
    () => PaintCatalogDetailViewModel(
      getIt<IPaintCatalogRepository>(),
    ),
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

  // ViewModels - Material
  getIt.registerFactory<MaterialListViewModel>(
    () => MaterialListViewModel(getIt<IMaterialRepository>()),
  );

  // ViewModels - Select Colors
  getIt.registerFactory<SelectColorsViewModel>(
    () => SelectColorsViewModel(
      getIt<IPaintCatalogRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModel - Quotes
  getIt.registerFactory<QuotesViewModel>(
    () => QuotesViewModel(),
  );

  getIt.registerFactory<ContactsViewModel>(
    () => ContactsViewModel(
      getIt<IContactRepository>(),
    ),
  );
}
