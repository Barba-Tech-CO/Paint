import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/dashboard/dashboard_view.dart';
import 'package:paintpro/view/projects/projects_view.dart';
import 'package:paintpro/view/camera/camera_view.dart';
import 'package:paintpro/view/contacts/contacts_view.dart';
import 'package:paintpro/view/highlights/highlights_view.dart';
import 'package:paintpro/view/layout/main_layout.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    ShellRoute(
      builder: (BuildContext context, GoRouterState state, Widget child) {
        return MainLayout(
          currentRoute: state.fullPath ?? '/',
          child: child,
        );
      },
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const DashboardView();
          },
        ),
        GoRoute(
          path: '/projects',
          builder: (BuildContext context, GoRouterState state) {
            return const ProjectsView();
          },
        ),
        GoRoute(
          path: '/camera',
          builder: (BuildContext context, GoRouterState state) {
            return const CameraView();
          },
        ),
        GoRoute(
          path: '/contacts',
          builder: (BuildContext context, GoRouterState state) {
            return const ContactsView();
          },
        ),
        GoRoute(
          path: '/highlights',
          builder: (BuildContext context, GoRouterState state) {
            return const HighlightsView();
          },
        ),
      ],
    ),
  ],
);
