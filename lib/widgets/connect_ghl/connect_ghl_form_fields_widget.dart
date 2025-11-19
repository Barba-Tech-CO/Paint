import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/connect_ghl/connect_ghl_viewmodel.dart';
import '../form_field/paint_pro_text_field.dart';

class ConnectGhlFormFieldsWidget extends StatelessWidget {
  final TextEditingController apiKeyController;
  final TextEditingController locationIdController;

  const ConnectGhlFormFieldsWidget({
    super.key,
    required this.apiKeyController,
    required this.locationIdController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Configuration',
          style: GoogleFonts.albertSans(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        Consumer<ConnectGhlViewModel>(
          builder: (context, viewModel, child) {
            return PaintProTextField(
              controller: apiKeyController,
              label: 'API Key',
              hintText: 'Enter your Go High Level API Key',
              isEnabled: !viewModel.isLoading,
            );
          },
        ),
        SizedBox(height: 8.h),
        Consumer<ConnectGhlViewModel>(
          builder: (context, viewModel, child) {
            return PaintProTextField(
              controller: locationIdController,
              label: 'Location ID',
              hintText: 'Enter your Location ID',
              isEnabled: !viewModel.isLoading,
            );
          },
        ),
      ],
    );
  }
}
