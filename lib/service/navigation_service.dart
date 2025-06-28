import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationService {
  static final NavigationService _instance = NavigationService._internal();
  factory NavigationService() => _instance;
  NavigationService._internal();

  void navigateToSplash(BuildContext context) {
    context.go('/splash');
  }

  void navigateToAuth(BuildContext context) {
    context.go('/auth');
  }

  void navigateToDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  void navigateToProjects(BuildContext context) {
    context.go('/projects');
  }

  void navigateToCamera(BuildContext context) {
    context.go('/camera');
  }

  void navigateToContacts(BuildContext context) {
    context.go('/contacts');
  }

  void navigateToHighlights(BuildContext context) {
    context.go('/highlights');
  }

  void replaceToDashboard(BuildContext context) {
    context.go('/dashboard');
  }

  void replaceToAuth(BuildContext context) {
    context.go('/auth');
  }

  void goBack(BuildContext context) {
    context.pop();
  }

  bool canGoBack(BuildContext context) {
    return context.canPop();
  }
}
