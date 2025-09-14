import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';

class CameraAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onDonePressed;
  final String instructionText;
  final bool isDoneEnabled;

  const CameraAppBar({
    super.key,
    this.onBackPressed,
    this.onDonePressed,
    this.instructionText = 'Take between 3 - 9 photos',
    this.isDoneEnabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: preferredSize.height,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 24, 8, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Back Button
            _buildActionButton(
              onPressed: onBackPressed,
              icon: Icons.arrow_back_ios,
              label: 'Back',
              backgroundColor: AppColors.gray50,
            ),

            // Center Instruction Text
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.gray24,
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Text(
                  instructionText,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.albertSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Done Button
            _buildActionButton(
              onPressed: isDoneEnabled ? onDonePressed : null,
              icon: Icons.arrow_forward_ios,
              label: 'Done',
              backgroundColor: isDoneEnabled
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.5),
              textColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color backgroundColor,
    Color textColor = Colors.white,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(
                icon,
                size: 18,
                color: textColor,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: textColor,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 18,
                color: textColor,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70.0);
}
