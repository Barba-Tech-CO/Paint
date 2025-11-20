import 'package:flutter/material.dart';

import '../../viewmodel/user/user_viewmodel.dart';
import '../../viewmodel/home/home_viewmodel.dart';
import 'drawer_header_widget.dart';

class DrawerHeaderContentWidget extends StatelessWidget {
  final UserViewModel? userViewModel;
  final HomeViewModel? homeViewModel;

  const DrawerHeaderContentWidget({
    super.key,
    this.userViewModel,
    this.homeViewModel,
  });

  @override
  Widget build(BuildContext context) {
    if (userViewModel == null || homeViewModel == null) {
      return const DrawerHeaderWidget(
        greeting: 'Welcome!',
        name: 'User',
      );
    }

    String displayName;
    if (userViewModel!.isLoading) {
      displayName = 'Loading...';
    } else if (userViewModel!.displayName.isNotEmpty) {
      displayName = userViewModel!.displayName;
    } else {
      displayName = 'User';
    }

    return DrawerHeaderWidget(
      greeting: homeViewModel!.getDynamicGreeting(),
      name: displayName,
    );
  }
}
