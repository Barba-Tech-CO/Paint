import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../layout/main_layout.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';

class HighlightsView extends StatelessWidget {
  const HighlightsView({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      currentRoute: '/highlights',
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: const PaintProAppBar(title: 'Go High Level'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lightbulb_outline,
                size: 64,
                color: AppColors.warning,
              ),
              const SizedBox(height: 16),
              Text(
                'Go High Level',
                style: GoogleFonts.albertSans(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your highlights will appear here',
                style: GoogleFonts.albertSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
