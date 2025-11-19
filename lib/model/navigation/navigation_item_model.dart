import 'package:flutter/material.dart';

class NavigationItemModel {
  final String id;
  final IconData? icon;
  final IconData? activeIcon;
  final String? iconAsset;
  final String? activeIconAsset;
  final String label;
  final String route;

  const NavigationItemModel({
    required this.id,
    this.icon,
    this.activeIcon,
    this.iconAsset,
    this.activeIconAsset,
    required this.label,
    required this.route,
  }) : assert(
         icon != null || iconAsset != null,
         'Either icon or iconAsset must be provided',
       );

  static List<NavigationItemModel> get defaultItems => [
    const NavigationItemModel(
      id: 'home',
      iconAsset: 'assets/icons/home.png',
      activeIconAsset: 'assets/icons/home.png',
      label: 'Home',
      route: '/home',
    ),
    const NavigationItemModel(
      id: 'projects',
      iconAsset: 'assets/icons/projects.png',
      activeIconAsset: 'assets/icons/projects.png',
      label: 'Projects',
      route: '/projects',
    ),
    const NavigationItemModel(
      id: 'contacts',
      iconAsset: 'assets/icons/contacts.png',
      activeIconAsset: 'assets/icons/contacts.png',
      label: 'Contacts',
      route: '/contacts',
    ),
    const NavigationItemModel(
      id: 'quotes',
      iconAsset: 'assets/icons/upload.png',
      activeIconAsset: 'assets/icons/upload.png',
      label: 'Uploads',
      route: '/quotes',
    ),
  ];
}
