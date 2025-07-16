import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../model/navigation_item_model.dart';

class NavigationViewModel extends ChangeNotifier {
  String _currentRoute = '/dashboard';
  final List<NavigationItemModel> _navigationItems =
      NavigationItemModel.defaultItems;

  NavigationViewModel();

  String get currentRoute => _currentRoute;
  List<NavigationItemModel> get navigationItems => _navigationItems;

  int get currentIndex {
    final index = _navigationItems.indexWhere(
      (item) => item.route == _currentRoute,
    );
    return index != -1 ? index : 0;
  }

  bool isActiveRoute(String route) {
    return _currentRoute == route;
  }

  void updateCurrentRoute(String route) {
    if (_currentRoute != route) {
      _currentRoute = route;
      notifyListeners();
    }
  }

  NavigationItemModel? getItemByRoute(String route) {
    try {
      return _navigationItems.firstWhere((item) => item.route == route);
    } catch (e) {
      return null;
    }
  }

  NavigationItemModel getItemByIndex(int index) {
    if (index >= 0 && index < _navigationItems.length) {
      return _navigationItems[index];
    }
    return _navigationItems.first;
  }
}

extension NavigationViewModelActions on NavigationViewModel {
  void onCameraTapped(BuildContext context) {
    updateCurrentRoute('/camera');
    context.go('/camera');
  }

  void onItemTapped(BuildContext context, NavigationItemModel item, int index) {
    if (_currentRoute != item.route) {
      updateCurrentRoute(item.route);
      context.go(item.route);
    }
  }
}
