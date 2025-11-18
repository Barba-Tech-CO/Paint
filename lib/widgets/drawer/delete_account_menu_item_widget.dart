import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../config/app_colors.dart';
import 'drawer_menu_item_widget.dart';

class DeleteAccountMenuItemWidget extends StatelessWidget {
  const DeleteAccountMenuItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return DrawerMenuItemWidget(
      icon: Icons.delete_forever_rounded,
      title: 'Delete Account',
      textColor: AppColors.error,
      iconColor: AppColors.error,
      onTap: () => context.push('/delete-account'),
    );
  }
}
