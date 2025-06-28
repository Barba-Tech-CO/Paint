import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/model/navigation_item_model.dart';
import 'package:paintpro/viewmodel/navigation_viewmodel.dart';

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
                      color: AppColors.primaryDark.withOpacity(0.1),
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
                              .map((
                                entry,
                              ) {
                                final index = entry.key;
                                final item = entry.value;
                                final isActive = viewModel.isActiveRoute(
                                  item.route,
                                );
                                return Expanded(
                                  child: _buildNavigationItem(
                                    context,
                                    item,
                                    isActive,
                                    index,
                                  ),
                                );
                              }),
                          // Empty space for camera button
                          const SizedBox(width: 80),
                          ...viewModel.navigationItems
                              .asMap()
                              .entries
                              .skip(2)
                              .map(
                                (
                                  entry,
                                ) {
                                  final index = entry.key + 1;
                                  final item = entry.value;
                                  final isActive = viewModel.isActiveRoute(
                                    item.route,
                                  );
                                  return Expanded(
                                    child: _buildNavigationItem(
                                      context,
                                      item,
                                      isActive,
                                      index,
                                    ),
                                  );
                                },
                              ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Pinned Camera Button
              Positioned(
                top: -4,
                child: _buildFloatingCameraButton(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNavigationItem(
    BuildContext context,
    NavigationItemModel item,
    bool isActive,
    int index,
  ) {
    return GestureDetector(
      onTap: () => _onItemTapped(context, item, index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? item.activeIcon : item.icon,
              color: isActive
                  ? AppColors.navigationActive
                  : AppColors.navigationInactive,
              size: 26,
            ),
            const SizedBox(height: 2),
            Flexible(
              child: Text(
                item.label,
                style: GoogleFonts.albertSans(
                  fontSize: 14,
                  color: isActive
                      ? AppColors.navigationActive
                      : AppColors.navigationInactive,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingCameraButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _onCameraTapped(context),
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          color: AppColors.buttonPrimary,
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primaryLight,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryDark.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.camera_alt,
          color: AppColors.textOnPrimary,
          size: 36,
        ),
      ),
    );
  }

  void _onCameraTapped(BuildContext context) {
    // Update ViewModel state
    viewModel.updateCurrentRoute('/camera');

    // Navigate to camera
    context.go('/camera');
  }

  void _onItemTapped(
    BuildContext context,
    NavigationItemModel item,
    int index,
  ) {
    // Update ViewModel state
    viewModel.updateCurrentRoute(item.route);

    // Navigate to new route
    context.go(item.route);
  }
}

class NotchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.navigationBackground
      ..style = PaintingStyle.fill;

    Path path = Path();

    // Notch width and position
    double notchWidth = 90;
    double notchHeight = 35;
    double notchMargin = (size.width - notchWidth) / 2;

    // Draw navbar outline with notch
    path.moveTo(0, notchHeight);
    path.lineTo(notchMargin - 10, notchHeight);

    // Left notch curve
    path.quadraticBezierTo(
      notchMargin,
      notchHeight,
      notchMargin + 10,
      notchHeight - 10,
    );

    // Top notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth / 2,
      -5,
      notchMargin + notchWidth - 10,
      notchHeight - 10,
    );

    // Right notch curve
    path.quadraticBezierTo(
      notchMargin + notchWidth,
      notchHeight,
      notchMargin + notchWidth + 10,
      notchHeight,
    );

    path.lineTo(size.width, notchHeight);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
