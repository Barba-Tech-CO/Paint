import 'package:flutter/material.dart';

import '../../../core/config/app_colors.dart';
import '../../../features/navigation/infrastructure/models/navigation_item_model.dart';
import '../../../features/navigation/presentation/viewmodels/navigation_viewmodel.dart';
import 'floating_camera_button_widget.dart';
import 'navigation_item_widget.dart';
import 'notch_painter.dart';

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
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // Bottom Navigation Bar with Notch
              Container(
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
                  child: CustomPaint(
                    painter: NotchPainter(),
                    child: Container(
                      height: 80,
                      padding: const EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 16,
                        bottom: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ...viewModel.navigationItems
                              .asMap()
                              .entries
                              .take(2)
                              .map((entry) {
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
                                    onTap: () =>
                                        _onItemTapped(context, item, index),
                                    semanticsLabel: 'Ir para ${item.label}',
                                  ),
                                );
                              }),
                          // Espaço vazio para o botão da câmera
                          const SizedBox(width: 80),
                          ...viewModel.navigationItems
                              .asMap()
                              .entries
                              .skip(2)
                              .map((entry) {
                                final index = entry.key + 1;
                                final item = entry.value;
                                final isActive = viewModel.isActiveRoute(
                                  item.route,
                                );
                                return Expanded(
                                  child: NavigationItemWidget(
                                    item: item,
                                    isActive: isActive,
                                    index: index,
                                    onTap: () =>
                                        _onItemTapped(context, item, index),
                                    semanticsLabel: 'Ir para ${item.label}',
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Botão da câmera fixo
              Positioned(
                top: -4,
                child: FloatingCameraButtonWidget(
                  onTap: () => _onCameraTapped(context),
                  semanticsLabel: 'Abrir câmera',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _onCameraTapped(BuildContext context) {
    viewModel.onCameraTapped(context);
  }

  void _onItemTapped(
    BuildContext context,
    NavigationItemModel item,
    int index,
  ) {
    viewModel.onItemTapped(context, item, index);
  }
}
