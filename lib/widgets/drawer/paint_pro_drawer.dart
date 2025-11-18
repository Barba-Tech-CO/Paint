import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/user/user_viewmodel.dart';
import '../../viewmodel/home/home_viewmodel.dart';
import 'connect_ghl_menu_item_widget.dart';
import 'delete_account_menu_item_widget.dart';
import 'drawer_header_content_widget.dart';
import 'logout_menu_item_widget.dart';

class PaintProDrawer extends StatelessWidget {
  final UserViewModel? userViewModel;
  final HomeViewModel? homeViewModel;

  const PaintProDrawer({
    super.key,
    this.userViewModel,
    this.homeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      elevation: 0,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            DrawerHeaderContentWidget(
              userViewModel: userViewModel,
              homeViewModel: homeViewModel,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: const [
                  ConnectGhlMenuItemWidget(),
                  SizedBox(height: 8),
                  DeleteAccountMenuItemWidget(),
                  SizedBox(height: 8),
                  LogoutMenuItemWidget(),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
