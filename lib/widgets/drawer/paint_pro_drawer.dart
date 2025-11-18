import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            SizedBox(height: 24.h),
            DrawerHeaderContentWidget(
              userViewModel: userViewModel,
              homeViewModel: homeViewModel,
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ConnectGhlMenuItemWidget(),
                  SizedBox(height: 8.h),
                  DeleteAccountMenuItemWidget(),
                  SizedBox(height: 8.h),
                  LogoutMenuItemWidget(),
                ],
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}
