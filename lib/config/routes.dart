import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../view/views.dart';
import '../features/auth/presentation/views/auth_view.dart';
import '../features/splash/presentation/viewmodels/splash_viewmodel.dart';
import '../features/home/presentation/viewmodels/home_viewmodel.dart';
import '../features/projects/presentation/viewmodels/projects_viewmodel.dart';
import '../features/highlights/presentation/viewmodels/highlights_viewmodel.dart';

final router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => SplashViewmodel(),
        child: const SplashView(),
      ),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => HomeViewmodel(),
        child: const HomeView(),
      ),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => ProjectsViewmodel(),
        child: const ProjectsView(),
      ),
    ),
    GoRoute(
      path: '/camera',
      builder: (context, state) => const CameraView(),
    ),
    GoRoute(
      path: '/contacts',
      builder: (context, state) => const ContactsView(),
    ),
    GoRoute(
      path: '/highlights',
      builder: (context, state) => ChangeNotifierProvider(
        create: (_) => HighlightsViewmodel(),
        child: const HighlightsView(),
      ),
    ),
    GoRoute(
      path: '/contact-details',
      builder: (context, state) => const ContactDetailsView(),
    ),
    GoRoute(
      path: '/create-project',
      builder: (context, state) => const CreateProjectView(),
    ),
    GoRoute(
      path: '/zones',
      builder: (context, state) => const ZonesView(),
    ),
    GoRoute(
      path: '/room-adjust',
      builder: (context, state) => const RoomAdjustView(),
    ),
    GoRoute(
      path: '/select-colors',
      builder: (context, state) => const SelectColorsView(),
    ),
    GoRoute(
      path: '/overview-zones',
      builder: (context, state) => const OverviewZonesView(),
    ),
    GoRoute(
      path: '/new-contact',
      builder: (context, state) => const NewContactView(),
    ),
  ],
);
