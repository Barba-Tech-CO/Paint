import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import '../items/delete_account_item_widget.dart';

class DeleteAccountItemsList extends StatelessWidget {
  const DeleteAccountItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What will be deleted:',
          style: GoogleFonts.albertSans(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        const DeleteAccountItemWidget(
          text: 'All your projects and estimates',
        ),
        const DeleteAccountItemWidget(
          text: 'All your contacts',
        ),
        const DeleteAccountItemWidget(
          text: 'All your materials and zones',
        ),
        const DeleteAccountItemWidget(
          text: 'Your account and profile information',
        ),
      ],
    );
  }
}
