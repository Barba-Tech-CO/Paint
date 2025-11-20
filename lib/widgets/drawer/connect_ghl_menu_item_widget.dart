import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import 'drawer_menu_item_widget.dart';

class ConnectGhlMenuItemWidget extends StatelessWidget {
  const ConnectGhlMenuItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerMenuItemWidget(
      icon: Icons.link,
      title: 'Connect Go High Level',
      textColor: AppColors.textPrimary,
      iconColor: AppColors.primary,
      onTap: () => _handleConnectGhl(context),
    );
  }

  void _handleConnectGhl(BuildContext context) {
    context.go('/connect-ghl');
  }
}
