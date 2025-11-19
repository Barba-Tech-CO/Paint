import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/auth/verify_otp_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_otp_field.dart';
import '../../utils/snackbar_utils.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;

  const VerifyOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  String _otpCode = '';

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Consumer<VerifyOtpViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.verificationSuccess) {
            context.go('/home');
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PaintProAppBar(
            title: 'Reset Password',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/login');
                }
              },
            ),
          ),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 32.h),
                            Center(
                              child: Text(
                                'Verify Your Email',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Center(
                              child: Text(
                                'Enter the 6-digit verification code',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            Center(
                              child: TextButton(
                                onPressed: viewModel.isLoading
                                    ? null
                                    : () async {
                                        final result = await viewModel
                                            .resendCode(widget.email);
                                        result.when(
                                          ok: (_) {
                                            SnackBarUtils.showSuccess(
                                              context,
                                              message:
                                                  'We sent a new code to your email.',
                                            );
                                          },
                                          error: (error) {
                                            SnackBarUtils.showError(
                                              context,
                                              message:
                                                  'Something went wrong. Please try again.',
                                            );
                                          },
                                        );
                                      },
                                child: Text(
                                  'Resend Code',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            PaintProOtpField(
                              onCompleted: (code) {
                                setState(() {
                                  _otpCode = code;
                                });
                              },
                              onChanged: (code) {
                                setState(() {
                                  _otpCode = code;
                                });
                              },
                            ),
                            SizedBox(height: 32.h),
                            PaintProButton(
                              text: 'Continue',
                              onPressed:
                                  (_otpCode.length == 6 && !viewModel.isLoading)
                                  ? () async {
                                      final result = await viewModel.verifyOtp(
                                        widget.email,
                                        _otpCode,
                                      );
                                      result.when(
                                        ok: (_) {},
                                        error: (error) {
                                          SnackBarUtils.showError(
                                            context,
                                            message:
                                                'Something went wrong. Please try again.',
                                          );
                                        },
                                      );
                                    }
                                  : null,
                              isLoading: viewModel.isLoading,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(double.infinity, 48.h),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: bottomInset + 16.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
