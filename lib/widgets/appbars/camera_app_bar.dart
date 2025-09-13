import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(
            left: 20.0,
            right: 20.0,
            top: 12.0,
            bottom: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button
              _buildActionButton(
                onPressed: onBackPressed,
                icon: Icons.arrow_back_ios,
                label: 'Back',
                backgroundColor: Colors.black.withValues(alpha: 0.6),
              ),

              // Center Instruction Text
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12.0),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 10.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Text(
                    instructionText,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.albertSans(
                      fontSize: 16,
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
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.black.withValues(alpha: 0.4),
                textColor: isDoneEnabled ? Colors.black : Colors.white,
              ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
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
                size: 14,
                color: textColor,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.albertSans(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              const SizedBox(width: 6),
              Icon(
                icon,
                size: 14,
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
