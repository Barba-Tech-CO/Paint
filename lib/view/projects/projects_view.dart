import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';

class ProjectsView extends StatelessWidget {
  const ProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaintProAppBar(title: 'Projects'),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.folder_outlined,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Projects',
              style: GoogleFonts.albertSans(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your projects will appear here',
              style: GoogleFonts.albertSans(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
