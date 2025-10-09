import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../service/auth_state_manager.dart';
import 'drawer_menu_item_widget.dart';

class LogoutMenuItemWidget extends StatelessWidget {
  const LogoutMenuItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerMenuItemWidget(
      icon: Icons.logout,
      title: 'Logout',
      textColor: AppColors.error,
      iconColor: AppColors.error,
      onTap: () => _handleLogout(context),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final authStateManager = getIt<AuthStateManager>();
    await authStateManager.logout();

    if (context.mounted) {
      context.go('/auth');
    }
  }
}
