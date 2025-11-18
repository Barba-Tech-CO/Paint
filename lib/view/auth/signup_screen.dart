import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';

import '../../config/app_colors.dart';
import '../../utils/validators/password_validator.dart';
import '../../viewmodel/auth/signup_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_password_field.dart';
import '../../widgets/form_field/paint_pro_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Consumer<SignUpViewModel>(
      builder: (context, viewModel, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (viewModel.signUpSuccess) {
            context.go('/home');
          }
        });

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const PaintProAppBar(title: 'Create Account'),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 32.h),
                            Center(
                              child: SvgPicture.asset(
                                'assets/logo/Logo.svg',
                                width: 100.w,
                                height: 100.h,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Center(
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            Center(
                              child: Text(
                                'Create your painting projects',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: AppColors.gray100,
                                ),
                              ),
                            ),
                            SizedBox(height: 32.h),
                            PaintProTextField(
                              label: 'Name:',
                              controller: _nameController,
                              hintText: 'Steve Jobs',
                              validator: Validatorless.required(
                                'Please enter your name',
                              ),
                            ),
                            PaintProTextField(
                              label: 'Email:',
                              controller: _emailController,
                              hintText: 'example@mail.com',
                              validator: Validatorless.multiple([
                                Validatorless.required(
                                  'Please enter your email',
                                ),
                                Validatorless.email(
                                  'Please enter a valid email',
                                ),
                              ]),
                            ),
                            PaintProPasswordField(
                              label: 'Password',
                              controller: _passwordController,
                              hintText: '**********',
                              validator: PasswordValidator.validate,
                            ),
                            SizedBox(height: 32.h),
                            PaintProButton(
                              text: 'Create Account',
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        viewModel.signUp(
                                          _nameController.text,
                                          _emailController.text,
                                          _passwordController.text,
                                        );
                                      }
                                    },
                              isLoading: viewModel.isLoading,
                              padding: EdgeInsets.zero,
                              minimumSize: Size(double.infinity, 48.h),
                            ),
                            SizedBox(height: 24.h),
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
                            SizedBox(height: 24.h),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24.h,
                      bottom: bottomInset + 16.h,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14.sp,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Login',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
