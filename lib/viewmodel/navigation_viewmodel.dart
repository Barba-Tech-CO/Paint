import 'package:flutter/foundation.dart';
import '../model/navigation_item_model.dart';

class NavigationViewModel extends ChangeNotifier {
  String _currentRoute = '/';
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
