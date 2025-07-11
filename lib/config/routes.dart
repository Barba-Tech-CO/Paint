import 'package:go_router/go_router.dart';

import 'package:paintpro/view/views.dart';

final router = GoRouter(
  initialLocation: '/new-contact',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthView(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardView(),
    ),
    GoRoute(
      path: '/projects',
      builder: (context, state) => const ProjectsView(),
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
      builder: (context, state) => const HighlightsView(),
    ),
    GoRoute(
      path: '/contact-details',
      builder: (context, state) => const ContactDetailsView(),
    ),
    GoRoute(
      path: '/new-project',
      builder: (context, state) => const NewProjectView(),
    ),
    GoRoute(
      path: '/measurements',
      builder: (context, state) => const MeasurementsView(),
    ),
    GoRoute(
      path: '/room-configuration',
      builder: (context, state) => const RoomConfigurationView(),
    ),
    GoRoute(
      path: '/new-contact',
      builder: (context, state) => const NewContactView(),
    ),
  ],
);
