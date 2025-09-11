import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependency_injection.dart';
import 'config/routes.dart';
import 'config/theme.dart';
import 'firebase_options.dart';
import 'service/location_service.dart';
import 'service/navigation_service.dart';
import 'viewmodel/auth/auth_viewmodel.dart';
import 'viewmodel/contact/contact_detail_viewmodel.dart';
import 'viewmodel/contact/contact_list_viewmodel.dart';
import 'viewmodel/contacts/contacts_viewmodel.dart';
import 'viewmodel/estimate/estimate_calculation_viewmodel.dart';
import 'viewmodel/estimate/estimate_detail_viewmodel.dart';
import 'viewmodel/estimate/estimate_list_viewmodel.dart';
import 'viewmodel/estimate/estimate_upload_viewmodel.dart';
import 'viewmodel/measurements/measurements_viewmodel.dart';
import 'viewmodel/navigation_viewmodel.dart';
import 'viewmodel/paint_catalog/paint_catalog_detail_viewmodel.dart';
import 'viewmodel/paint_catalog/paint_catalog_list_viewmodel.dart';
import 'viewmodel/projects/projects_viewmodel.dart';
import 'viewmodel/quotes/quotes_viewmodel.dart';
import 'viewmodel/zones/zones_card_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configura Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  // Configura injeção de dependências
  setupDependencyInjection();

  runApp(const PaintProApp());
}

class PaintProApp extends StatelessWidget {
  const PaintProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Auth ViewModels
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
        ),
        // Contact ViewModels
        ChangeNotifierProvider<ContactListViewModel>(
          create: (_) => getIt<ContactListViewModel>(),
        ),
        ChangeNotifierProvider<ContactDetailViewModel>(
          create: (_) => getIt<ContactDetailViewModel>(),
        ),
        // Estimate ViewModels
        ChangeNotifierProvider<EstimateListViewModel>(
          create: (_) => getIt<EstimateListViewModel>(),
        ),
        ChangeNotifierProvider<EstimateDetailViewModel>(
          create: (_) => getIt<EstimateDetailViewModel>(),
        ),
        ChangeNotifierProvider<EstimateUploadViewModel>(
          create: (_) => getIt<EstimateUploadViewModel>(),
        ),
        ChangeNotifierProvider<EstimateCalculationViewModel>(
          create: (_) => getIt<EstimateCalculationViewModel>(),
        ),
        // Paint Catalog ViewModels
        ChangeNotifierProvider<PaintCatalogListViewModel>(
          create: (_) => getIt<PaintCatalogListViewModel>(),
        ),
        ChangeNotifierProvider<PaintCatalogDetailViewModel>(
          create: (_) => getIt<PaintCatalogDetailViewModel>(),
        ),
        // Navigation
        ChangeNotifierProvider<NavigationViewModel>(
          create: (_) => getIt<NavigationViewModel>(),
        ),
        Provider<NavigationService>(
          create: (_) => getIt<NavigationService>(),
        ),
        // Measurements ViewModel
        ChangeNotifierProvider<MeasurementsViewModel>(
          create: (_) => getIt<MeasurementsViewModel>(),
        ),
        // Zones ViewModel
        ChangeNotifierProvider<ZonesCardViewmodel>(
          create: (_) => getIt<ZonesCardViewmodel>(),
        ),
        // Quotes ViewModel
        ChangeNotifierProvider<QuotesViewModel>(
          create: (_) => getIt<QuotesViewModel>(),
        ),
        ChangeNotifierProvider<ContactsViewModel>(
          create: (_) => getIt<ContactsViewModel>(),
        ),
        // Location Service
        ChangeNotifierProvider<LocationService>(
          create: (_) => getIt<LocationService>(),
        ),
        ChangeNotifierProvider<ProjectsViewModel>(
          create: (_) => getIt<ProjectsViewModel>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Paint Estimator',
        theme: AppTheme.themeData,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
