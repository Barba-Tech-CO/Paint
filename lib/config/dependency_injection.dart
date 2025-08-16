import 'package:get_it/get_it.dart';

import 'package:paintpro/viewmodel/viewmodels.dart';
import '../viewmodel/select_colors_viewmodel.dart';

import '../service/app_initialization_service.dart';
import '../service/auth_service.dart';
import '../service/contact_service.dart';
import '../service/deep_link_service.dart';
import '../service/estimate_service.dart';
import '../service/http_service.dart';
import '../service/logger_service.dart';
import '../service/navigation_service.dart';
import '../service/paint_catalog_service.dart';
import '../use_case/auth/auth_use_cases.dart';
import '../utils/logger/app_logger.dart';
import '../utils/logger/logger_app_logger_impl.dart';

final GetIt getIt = GetIt.instance;

void setupDependencyInjection() {
  // Serviços
  getIt.registerLazySingleton<HttpService>(
    () {
      final httpService = HttpService();
      httpService.setLogger(getIt<LoggerService>());
      return httpService;
    },
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
  getIt.registerLazySingleton<LoggerService>(
    () => LoggerService(getIt<AppLogger>()),
  );

  // Use Cases
  getIt.registerLazySingleton<AuthOperationsUseCase>(
    () => AuthOperationsUseCase(getIt<AuthService>(), getIt<LoggerService>()),
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
    () => ContactListViewModel(getIt<ContactService>()),
  );
  getIt.registerFactory<ContactDetailViewModel>(
    () => ContactDetailViewModel(getIt<ContactService>()),
  );

  // ViewModels - Estimate
  getIt.registerFactory<EstimateListViewModel>(
    () => EstimateListViewModel(getIt<EstimateService>()),
  );
  getIt.registerFactory<EstimateDetailViewModel>(
    () => EstimateDetailViewModel(getIt<EstimateService>()),
  );
  getIt.registerFactory<EstimateUploadViewModel>(
    () => EstimateUploadViewModel(getIt<EstimateService>()),
  );
  getIt.registerFactory<EstimateCalculationViewModel>(
    () => EstimateCalculationViewModel(getIt<EstimateService>()),
  );

  // ViewModels - Paint Catalog
  getIt.registerFactory<PaintCatalogListViewModel>(
    () => PaintCatalogListViewModel(getIt<PaintCatalogService>()),
  );
  getIt.registerFactory<PaintCatalogDetailViewModel>(
    () => PaintCatalogDetailViewModel(getIt<PaintCatalogService>()),
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
    () => SelectColorsViewModel(getIt<LoggerService>()),
  );
}
