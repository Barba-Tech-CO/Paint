import 'package:get_it/get_it.dart';
import '../service/http_service.dart';
import '../service/auth_service.dart';
import '../service/contact_service.dart';
import '../service/estimate_service.dart';
import '../service/paint_catalog_service.dart';
import '../service/navigation_service.dart';
import '../service/app_initialization_service.dart';
import '../viewmodel/auth/auth_viewmodel.dart';
import '../viewmodel/auth/profile_viewmodel.dart';
import '../viewmodel/contact/contact_list_viewmodel.dart';
import '../viewmodel/contact/contact_detail_viewmodel.dart';
import '../viewmodel/estimate/estimate_list_viewmodel.dart';
import '../viewmodel/estimate/estimate_detail_viewmodel.dart';
import '../viewmodel/estimate/estimate_upload_viewmodel.dart';
import '../viewmodel/estimate/estimate_calculation_viewmodel.dart';
import '../viewmodel/paint_catalog/paint_catalog_list_viewmodel.dart';
import '../viewmodel/paint_catalog/paint_catalog_detail_viewmodel.dart';
import '../viewmodel/navigation_viewmodel.dart';

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
  getIt.registerLazySingleton<AppInitializationService>(
    () => AppInitializationService(
      getIt<AuthService>(),
      getIt<NavigationService>(),
    ),
  );

  // ViewModels - Auth
  getIt.registerFactory<AuthViewModel>(
    () => AuthViewModel(getIt<AuthService>()),
  );
  getIt.registerFactory<ProfileViewModel>(
    () => ProfileViewModel(getIt<AuthService>()),
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
    () => NavigationViewModel(getIt<NavigationService>()),
  );
}
