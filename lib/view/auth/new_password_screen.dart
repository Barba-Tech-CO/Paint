import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';

import '../../viewmodel/auth/reset_password_viewmodel.dart';
import '../../viewmodel/auth/verify_otp_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_password_field.dart';
import '../../utils/snackbar_utils.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final verifyOtpViewModel = context.watch<VerifyOtpViewModel>();

    return Consumer<ResetPasswordViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.resetSuccess) {
            verifyOtpViewModel.clearVerificationData();
            SnackBarUtils.showSuccess(
              context,
              message: 'Password reset successfully! Please login.',
            );
            context.go('/login');
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PaintProAppBar(
            title: 'New Password',
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
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(height: 32.h),
                              Center(
                                child: Text(
                                  'Create New Password',
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
                                  'Enter a strong password for your account',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                              SizedBox(height: 32.h),
                              PaintProPasswordField(
                                label: 'New Password',
                                controller: _passwordController,
                                hintText: '**********',
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                    'Please enter a password',
                                  ),
                                  Validatorless.min(
                                    8,
                                    'Password must be at least 8 characters',
                                  ),
                                ]),
                              ),
                              SizedBox(height: 16.h),
                              PaintProPasswordField(
                                label: 'Confirm Password',
                                controller: _confirmPasswordController,
                                hintText: '**********',
                                validator: Validatorless.multiple([
                                  Validatorless.required(
                                    'Please confirm your password',
                                  ),
                                  Validatorless.compare(
                                    _passwordController,
                                    'Passwords do not match',
                                  ),
                                ]),
                              ),
                              SizedBox(height: 32.h),
                              PaintProButton(
                                text: 'Reset Password',
                                onPressed: (!viewModel.isLoading)
                                    ? () async {
                                        if (_formKey.currentState?.validate() ??
                                            false) {
                                          final email =
                                              verifyOtpViewModel
                                                  .verifiedEmail ??
                                              '';
                                          final token =
                                              verifyOtpViewModel
                                                  .verifiedToken ??
                                              '';

                                          if (email.isEmpty || token.isEmpty) {
                                            SnackBarUtils.showError(
                                              context,
                                              message:
                                                  'Session expired. Please try again.',
                                            );
                                            context.go('/login');
                                            return;
                                          }

                                          final result = await viewModel
                                              .resetPassword(
                                                email,
                                                token,
                                                _passwordController.text,
                                              );

                                          result.when(
                                            ok: (_) {},
                                            error: (error) {
                                              SnackBarUtils.showError(
                                                context,
                                                message:
                                                    viewModel.errorMessage ??
                                                    'Failed to reset password. Please try again.',
                                              );
                                            },
                                          );
                                        }
                                      }
                                    : null,
                                isLoading: viewModel.isLoading,
                                padding: EdgeInsets.zero,
                                minimumSize: Size(double.infinity, 48.h),
                              ),
                              SizedBox(height: 16.h),
                              if (viewModel.errorMessage != null)
                                Container(
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(8.r),
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                  ),
                                  child: Text(
                                    viewModel.errorMessage!,
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 14.sp,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          ),
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
