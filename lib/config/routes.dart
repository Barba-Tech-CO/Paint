import 'package:go_router/go_router.dart';
import 'package:paintpro/view/contact_details/contact_details_view.dart';

import '../view/splash/splash_view.dart';
import '../view/auth/auth_view.dart';
import '../view/dashboard/dashboard_view.dart';
import '../view/projects/projects_view.dart';
import '../view/camera/camera_view.dart';
import '../view/contacts/contacts_view.dart';
import '../view/highlights/highlights_view.dart';

final router = GoRouter(
  initialLocation: '/splash',
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
  ],
);
