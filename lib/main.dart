import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Configs
import 'config/dependency_injection.dart';
import 'config/routes.dart';
import 'config/theme.dart';

// Features
import 'features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'firebase_options.dart';
import 'service/navigation_service.dart';

// Viewmodels
import 'features/contacts/presentation/viewmodels/contact_list_viewmodel.dart';
import 'features/contacts/presentation/viewmodels/contact_detail_viewmodel.dart';
import 'features/measurements/presentation/viewmodels/measurements_viewmodel.dart';
import 'features/navigation/presentation/viewmodels/navigation_viewmodel.dart';

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

      ],
      child: MaterialApp.router(
        title: 'PaintPro',
        theme: AppTheme.themeData,
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
