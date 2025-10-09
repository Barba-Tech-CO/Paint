import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';

class InstructionStepWidget extends StatelessWidget {
  final String text;

  const InstructionStepWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.albertSans(
        fontSize: 14,
        color: AppColors.textOnPrimary.withValues(alpha: 0.9),
        height: 1.4,
      ),
    );
  }
}
