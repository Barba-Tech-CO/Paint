import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/app_colors.dart';
import 'instruction_step_widget.dart';

class ConnectGhlInfoCardWidget extends StatelessWidget {
  const ConnectGhlInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect Go High Level',
            style: GoogleFonts.albertSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const InstructionStepWidget(
                text: '1. Log into your Go High Level account',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '2. Go to Settings → Private Integrations',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '3. Click "Create New Integration"',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '4. Set a name like "Paint Estimator"',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text:
                    '5. Select scopes: "View bussines, View contacts, Edit contacts, View locations, invoiceesestimatewrite"',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '6. Copy the generated token',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '7. For Location ID: Settings → Business Profile',
              ),
              SizedBox(height: 8.h),
              const InstructionStepWidget(
                text: '8. Paste both values in the app below',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
