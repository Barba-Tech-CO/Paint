import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Data Layer
import '../data/repository/auth_repository_impl.dart';
import '../data/repository/contact_repository_impl.dart';
import '../data/repository/dashboard_repository_impl.dart';
import '../data/repository/estimate_repository_impl.dart';
import '../data/repository/estimate_detail_repository_impl.dart';
import '../data/repository/material_repository_impl.dart';
import '../data/repository/offline_repository_impl.dart';
import '../data/repository/paint_catalog_repository_impl.dart';
import '../data/repository/quote_repository_impl.dart';
import '../data/repository/user_repository_impl.dart';

// Domain Layer
import '../domain/repository/auth_repository.dart';
import '../domain/repository/contact_repository.dart';
import '../domain/repository/dashboard_repository.dart';
import '../domain/repository/estimate_repository.dart';
import '../domain/repository/estimate_detail_repository.dart';
import '../domain/repository/material_repository.dart';
import '../domain/repository/offline_repository.dart';
import '../domain/repository/paint_catalog_repository.dart';
import '../domain/repository/quote_repository.dart';
import '../domain/repository/user_repository.dart';

// Service Layer
import '../service/app_initialization_service.dart';
import '../service/auth_service.dart';
import '../service/auth_initialization_service.dart';
import '../service/auth_persistence_service.dart';
import '../service/auth_state_manager.dart';
import '../service/camera_service.dart';
import '../service/contact_service.dart';
import '../service/contact_database_service.dart';
import '../service/contact_loading_service.dart';
import '../service/dashboard_service.dart';
import '../service/deep_link_service.dart';
import '../service/estimate_service.dart';
import '../service/http_service.dart';
import '../service/location_service.dart';
import '../service/material_service.dart';
import '../service/material_database_service.dart';
import '../service/paint_catalog_service.dart';
import '../service/photo_service.dart';
import '../service/quote_service.dart';
import '../service/sync_service.dart';
import '../service/database_service.dart';
import '../service/local/estimates_local_service.dart';
import '../service/local/pending_operations_local_service.dart';
import '../service/local/dashboard_cache_local_service.dart';
import '../service/local/quotes_local_service.dart';
import '../service/user_service.dart';
import '../service/zones_service.dart';
import '../service/i_zones_service.dart';

// Logger Layer
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

// Use Case Layer
import '../use_case/auth/auth_operations_use_case.dart';
import '../use_case/auth/manage_auth_state_use_case.dart';
import '../use_case/auth/handle_deep_link_use_case.dart';
import '../use_case/auth/handle_webview_navigation_use_case.dart';
import '../use_case/contacts/contact_operations_use_case.dart';
import '../use_case/contacts/contact_sync_use_case.dart';
import '../use_case/dashboard/dashboard_financial_use_case.dart';
import '../use_case/estimates/estimate_upload_use_case.dart';
import '../use_case/estimate/estimate_detail_use_case.dart';
import '../use_case/projects/project_operations_use_case.dart';
import '../use_case/quotes/quote_upload_use_case.dart';

// ViewModel Layer
import '../viewmodel/select_colors_viewmodel.dart';
import '../viewmodel/auth/auth_viewmodel.dart';
import '../viewmodel/auth/login_viewmodel.dart';
import '../viewmodel/auth/signup_viewmodel.dart';
import '../viewmodel/auth/verify_otp_viewmodel.dart';
import '../viewmodel/auth/reset_password_viewmodel.dart';
import '../viewmodel/contact/contact_list_viewmodel.dart';
import '../viewmodel/contact/contact_detail_viewmodel.dart';
import '../viewmodel/contact/new_contact_viewmodel.dart';
import '../viewmodel/contacts/contacts_viewmodel.dart';
import '../viewmodel/edit_zone/edit_zone_viewmodel.dart';
import '../viewmodel/estimate/estimate_list_viewmodel.dart';
import '../viewmodel/estimate/estimate_detail_viewmodel.dart';
import '../viewmodel/estimate/estimate_upload_viewmodel.dart';
import '../viewmodel/estimate/estimate_calculation_viewmodel.dart';
import '../viewmodel/material/material_list_viewmodel.dart';
import '../viewmodel/measurements/measurements_viewmodel.dart';
import '../viewmodel/dashboard/dashboard_viewmodel.dart';
import '../viewmodel/navigation_viewmodel.dart';
import '../viewmodel/projects/projects_viewmodel.dart';
import '../viewmodel/home/home_viewmodel.dart';
import '../viewmodel/quotes/quotes_viewmodel.dart';
import '../viewmodel/roomplan/roomplan_viewmodel.dart';
import '../viewmodel/user/user_viewmodel.dart';
import '../viewmodel/zones/zones_list_viewmodel.dart';
import '../viewmodel/zones/zone_detail_viewmodel.dart';
import '../viewmodel/zones/zones_summary_viewmodel.dart';
import '../viewmodel/zones/zones_card_viewmodel.dart';

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

  getIt.registerLazySingleton<AuthStateManager>(
    () => AuthStateManager(),
  );

  getIt.registerLazySingleton<AuthPersistenceService>(
    () => AuthPersistenceService(),
  );

  getIt.registerLazySingleton<AuthService>(
    () => AuthService(
      getIt<HttpService>(),
      getIt<AuthPersistenceService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<LocationService>(
    () => LocationService(),
  );
  getIt.registerLazySingleton<ContactService>(
    () => ContactService(
      getIt<HttpService>(),
      getIt<AppLogger>(),
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
  getIt.registerLazySingleton<DashboardService>(
    () => DashboardService(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<MaterialDatabaseService>(
    () => MaterialDatabaseService(),
  );

  getIt.registerLazySingleton<MaterialService>(
    () => MaterialService(
      getIt<QuoteService>(),
      getIt<MaterialDatabaseService>(),
    ),
  );
  getIt.registerLazySingleton<PaintCatalogService>(
    () => PaintCatalogService(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<DeepLinkService>(
    () => DeepLinkService(),
  );
  getIt.registerLazySingleton<ContactLoadingService>(
    () => ContactLoadingService(
      contactRepository: getIt<IContactRepository>(),
      httpService: getIt<HttpService>(),
      authPersistenceService: getIt<AuthPersistenceService>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<UserService>(
    () => UserService(
      getIt<HttpService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<QuoteService>(
    () => QuoteService(
      httpService: getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<PhotoService>(
    () => PhotoService(),
  );
  getIt.registerLazySingleton<CameraService>(
    () => CameraService(),
  );
  getIt.registerLazySingleton<IZonesService>(
    () => ZonesService(),
  );

  // Database + Local Services
  getIt.registerLazySingleton<DatabaseService>(() => DatabaseService());
  getIt.registerLazySingleton<EstimatesLocalService>(
    () => EstimatesLocalService(
      getIt<DatabaseService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<PendingOperationsLocalService>(
    () => PendingOperationsLocalService(
      getIt<DatabaseService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<DashboardCacheLocalService>(
    () => DashboardCacheLocalService(
      getIt<DatabaseService>(),
    ),
  );
  getIt.registerLazySingleton<QuotesLocalService>(
    () => QuotesLocalService(
      getIt<DatabaseService>(),
    ),
  );

  // User Service and Repository (needed early for AuthInitializationService)
  getIt.registerLazySingleton<IUserRepository>(
    () => UserRepositoryImpl(
      getIt<UserService>(),
    ),
  );

  getIt.registerLazySingleton<UserViewModel>(
    () => UserViewModel(
      getIt<IUserRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // Auth Initialization Service (after UserViewModel)
  getIt.registerLazySingleton<AuthInitializationService>(
    () => AuthInitializationService(
      authPersistenceService: getIt<AuthPersistenceService>(),
      userViewModel: getIt<UserViewModel>(),
      httpService: getIt<HttpService>(),
    ),
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
      userService: getIt<UserService>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<IEstimateRepository>(
    () => EstimateRepository(
      estimateService: getIt<EstimateService>(),
      offlineRepository: getIt<IOfflineRepository>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<IEstimateDetailRepository>(
    () => EstimateDetailRepositoryImpl(
      getIt<HttpService>(),
    ),
  );
  getIt.registerLazySingleton<IDashboardRepository>(
    () => DashboardRepositoryImpl(
      getIt<DashboardService>(),
      getIt<DashboardCacheLocalService>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<IMaterialRepository>(
    () => MaterialRepository(
      materialService: getIt<MaterialService>(),
      logger: getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<IPaintCatalogRepository>(
    () => PaintCatalogRepository(
      paintCatalogService: getIt<PaintCatalogService>(),
    ),
  );
  getIt.registerLazySingleton<IQuoteRepository>(
    () => QuoteRepository(
      quoteService: getIt<QuoteService>(),
      localStorageService: getIt<QuotesLocalService>(),
      logger: getIt<AppLogger>(),
    ),
  );

  getIt.registerLazySingleton<IOfflineRepository>(
    () => OfflineRepository(
      getIt<EstimatesLocalService>(),
      getIt<PendingOperationsLocalService>(),
      getIt<DatabaseService>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerLazySingleton<SyncService>(
    () => SyncService(
      getIt<IEstimateRepository>(),
      getIt<IOfflineRepository>(),
      Connectivity(),
      getIt<AppLogger>(),
    ),
  );

  // Use Cases - Auth
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
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<HandleWebViewNavigationUseCase>(
    () => HandleWebViewNavigationUseCase(),
  );

  // Use Cases - Contacts
  getIt.registerLazySingleton<ContactOperationsUseCase>(
    () => ContactOperationsUseCase(
      getIt<IContactRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<ContactSyncUseCase>(
    () => ContactSyncUseCase(
      getIt<IContactRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // Use Cases - Quotes
  getIt.registerLazySingleton<QuoteUploadUseCase>(
    () => QuoteUploadUseCase(
      getIt<IQuoteRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // Use Cases - Estimates
  getIt.registerLazySingleton<EstimateUploadUseCase>(
    () => EstimateUploadUseCase(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );
  getIt.registerLazySingleton<EstimateDetailUseCase>(
    () => EstimateDetailUseCase(
      getIt<IEstimateDetailRepository>(),
    ),
  );

  // Use Cases - Projects
  getIt.registerLazySingleton<ProjectOperationsUseCase>(
    () => ProjectOperationsUseCase(
      getIt<IEstimateRepository>(),
      getIt<AppLogger>(),
    ),
  );

  // Use Cases - Dashboard Financial
  getIt.registerLazySingleton<DashboardFinancialUseCase>(
    () => DashboardFinancialUseCase(
      getIt<IDashboardRepository>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerLazySingleton<AppInitializationService>(
    () => AppInitializationService(
      getIt<AuthService>(),
      getIt<AuthPersistenceService>(),
      getIt<AuthStateManager>(),
      getIt<DeepLinkService>(),
      getIt<HttpService>(),
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
      getIt<HttpService>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(
      getIt<HttpService>(),
      getIt<AuthPersistenceService>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerFactory<SignUpViewModel>(
    () => SignUpViewModel(
      getIt<HttpService>(),
      getIt<AuthPersistenceService>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerFactory<VerifyOtpViewModel>(
    () => VerifyOtpViewModel(
      getIt<HttpService>(),
      getIt<AppLogger>(),
    ),
  );

  getIt.registerFactory<ResetPasswordViewModel>(
    () => ResetPasswordViewModel(
      getIt<HttpService>(),
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
    ),
  );
  getIt.registerFactory<NewContactViewModel>(
    () => NewContactViewModel(
      getIt<ContactDetailViewModel>(),
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
      getIt<EstimateDetailUseCase>(),
      getIt<IMaterialRepository>(),
    ),
  );
  getIt.registerFactory<EstimateUploadViewModel>(
    () => EstimateUploadViewModel(
      getIt<EstimateUploadUseCase>(),
    ),
  );
  getIt.registerFactory<EstimateCalculationViewModel>(
    () => EstimateCalculationViewModel(
      getIt<IEstimateRepository>(),
      getIt<PhotoService>(),
    ),
  );

  // ViewModels - Navigation
  getIt.registerFactory<NavigationViewModel>(
    () => NavigationViewModel(),
  );

  // ViewModels - Measurements
  getIt.registerFactory<MeasurementsViewModel>(
    () => MeasurementsViewModel(
      getIt<IOfflineRepository>(),
      getIt<SyncService>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Zones (Refactored)
  getIt.registerLazySingleton<ZonesListViewModel>(
    () => ZonesListViewModel(
      getIt<IZonesService>(),
    ),
  );

  getIt.registerLazySingleton<ZoneDetailViewModel>(
    () => ZoneDetailViewModel(
      getIt<IZonesService>(),
    ),
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
    () => MaterialListViewModel(
      getIt<IMaterialRepository>(),
    ),
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
    () => QuotesViewModel(
      getIt<QuoteUploadUseCase>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModels - Contacts
  getIt.registerFactory<ContactsViewModel>(
    () => ContactsViewModel(
      getIt<ContactOperationsUseCase>(),
    ),
  );

  // ViewModel - Projects
  getIt.registerFactory<ProjectsViewModel>(
    () => ProjectsViewModel(
      getIt<ProjectOperationsUseCase>(),
      getIt<AppLogger>(),
    ),
  );

  // ViewModel - Home
  getIt.registerFactory<HomeViewModel>(
    () => HomeViewModel(
      getIt<IEstimateRepository>(),
    ),
  );

  // ViewModel - Dashboard
  getIt.registerFactory<DashboardViewModel>(
    () => DashboardViewModel(
      getIt<IDashboardRepository>(),
      getIt<DashboardFinancialUseCase>(),
    ),
  );

  // ViewModel - RoomPlan
  getIt.registerFactory<RoomPlanViewModel>(
    () => RoomPlanViewModel(),
  );

  // ViewModel - EditZone
  getIt.registerFactory<EditZoneViewModel>(
    () => EditZoneViewModel(),
  );
}
