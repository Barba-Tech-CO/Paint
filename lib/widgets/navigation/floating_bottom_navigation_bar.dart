import 'package:flutter/material.dart';

import '../../config/app_colors.dart';
import '../../model/navigation/navigation_item_model.dart';
import '../../viewmodel/navigation_viewmodel.dart';
import 'navigation_item_widget.dart';

class FloatingBottomNavigationBar extends StatelessWidget {
  final NavigationViewModel viewModel;

  const FloatingBottomNavigationBar({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: viewModel,
      builder: (context, child) {
        return SizedBox(
          height: 120,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.navigationBackground,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryDark.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: Container(
                height: 88,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: viewModel.navigationItems.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final item = entry.value;
                    final isActive = viewModel.isActiveRoute(
                      item.route,
                    );
                    return Expanded(
                      child: NavigationItemWidget(
                        item: item,
                        isActive: isActive,
                        index: index,
                        onTap: () => _onItemTapped(context, item, index),
                        semanticsLabel: 'Go to ${item.label}',
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onItemTapped(
    BuildContext context,
    NavigationItemModel item,
    int index,
  ) {
    viewModel.onItemTapped(context, item, index);
  }
}
