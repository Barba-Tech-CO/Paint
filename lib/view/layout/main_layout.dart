import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/dependency_injection.dart';
import '../../utils/logger/app_logger.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import '../widgets/navigation/floating_bottom_navigation_bar.dart';

class MainLayout extends StatefulWidget {
  final Widget child;
  final String currentRoute;

  const MainLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late NavigationViewModel _navigationViewModel;

  @override
  void initState() {
    super.initState();
    _navigationViewModel = NavigationViewModel(getIt<AppLogger>());
    _navigationViewModel.updateCurrentRoute(widget.currentRoute);
  }

  @override
  void didUpdateWidget(MainLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute) {
      _navigationViewModel.updateCurrentRoute(widget.currentRoute);
    }
  }

  @override
  void dispose() {
    _navigationViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NavigationViewModel>.value(
      value: _navigationViewModel,
      child: Scaffold(
        body: widget.child,
        extendBody: true,
        bottomNavigationBar: Consumer<NavigationViewModel>(
          builder: (context, viewModel, child) {
            return FloatingBottomNavigationBar(
              viewModel: viewModel,
            );
          },
        ),
      ),
    );
  }
}
