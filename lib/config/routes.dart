import 'package:go_router/go_router.dart';

import '../view/splash/splash_view.dart';
import '../view/auth/auth_view.dart';
import '../view/dashboard/dashboard_view.dart';
import '../view/projects/projects_view.dart';
import '../view/camera/camera_view.dart';
import '../view/contacts/contacts_view.dart';
import '../view/highlights/highlights_view.dart';
import '../view/contact_details/contact_details_view.dart';
import '../view/new_project/new_project_view.dart';
import '../view/measurements/measurements_view.dart';
import '../view/room_configuration/room_configuration_view.dart';
import '../view/widgets/webview_popup_screen.dart';
import '../view/views.dart';

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
    GoRoute(
      path: '/new-project',
      builder: (context, state) => const NewProjectView(),
    ),
    GoRoute(
      path: '/measurements',
      builder: (context, state) => const MeasurementsView(),
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
      path: '/overview-measurements',
      builder: (context, state) => const OverviewMeasurementsView(),
    ),
    GoRoute(
      path: '/webview-popup',
      builder: (context, state) {
        final url = state.extra as String;
        return WebViewPopupScreen(popupUrl: url);
      },
    ),
  ],
);
