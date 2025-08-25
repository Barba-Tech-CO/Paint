import 'package:flutter/material.dart';

class NavigationItemModel {
  final String id;
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String route;

  const NavigationItemModel({
    required this.id,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.route,
  });

  static List<NavigationItemModel> get defaultItems => [
    const NavigationItemModel(
      id: 'home',
      icon: Icons.home_rounded,
      activeIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    const NavigationItemModel(
      id: 'projects',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view,
      label: 'Projects',
      route: '/projects',
    ),
    const NavigationItemModel(
      id: 'contacts',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people,
      label: 'Contacts',
      route: '/contacts',
    ),
    const NavigationItemModel(
      id: 'uploads',
      icon: Icons.link_rounded,
      activeIcon: Icons.create_new_folder_sharp,
      label: 'Uploads',
      route: '/quotes',
    ),
  ];
}
