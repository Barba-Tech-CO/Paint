import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../view/views.dart';
import '../view/widgets/webview_popup_screen.dart';

Page<dynamic> slideTransitionPage(Widget child, GoRouterState state) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      var tween = Tween(
        begin: begin,
        end: end,
      ).chain(CurveTween(curve: Curves.ease));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

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
      pageBuilder: (context, state) {
        return slideTransitionPage(const DashboardView(), state);
      },
    ),
    GoRoute(
      path: '/projects',
      pageBuilder: (context, state) {
        return slideTransitionPage(const ProjectsView(), state);
      },
    ),
    GoRoute(
      path: '/camera',
      pageBuilder: (context, state) {
        return slideTransitionPage(const CameraView(), state);
      },
    ),
    GoRoute(
      path: '/contacts',
      pageBuilder: (context, state) {
        return slideTransitionPage(const ContactsView(), state);
      },
    ),
    GoRoute(
      path: '/highlights',
      pageBuilder: (context, state) {
        return slideTransitionPage(const HighlightsView(), state);
      },
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
