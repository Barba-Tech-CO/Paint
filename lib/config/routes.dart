import 'package:go_router/go_router.dart';

import '../view/views.dart';
import '../view/widgets/webview_popup_screen.dart';

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
