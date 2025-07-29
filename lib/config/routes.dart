import 'package:go_router/go_router.dart';

import 'package:paintpro/view/views.dart';

final router = GoRouter(
  initialLocation: '/zones-details',
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
    GoRoute(
      path: '/zones-details',
      builder: (context, state) => const ZonesDetails(),
    ),
  ],
);
