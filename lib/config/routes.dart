import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/view/dashboard/dashboard_view.dart';

final GoRouter router = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      //TODO: Atualizar a rota inicial depois
      path: '/',
      builder: (BuildContext context, GoRouterState state) {
        return const DashboardView();
      },
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'details',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const DetailsScreen();
      //     },
      //   ),
      // ],
    ),
  ],
);
