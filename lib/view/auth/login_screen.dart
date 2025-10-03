import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:validatorless/validatorless.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/auth/login_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_password_field.dart';
import '../../widgets/form_field/paint_pro_text_field.dart';
import '../../utils/snackbar_utils.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Consumer<LoginViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const PaintProAppBar(title: 'Login'),
          body: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
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
                            const SizedBox(height: 32),
                            Center(
                              child: SvgPicture.asset(
                                'assets/logo/Logo.svg',
                                width: 120,
                                height: 120,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const Center(
                              child: Text(
                                'Access your paintin projects',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray100,
                                ),
                              ),
                            ),
                            const SizedBox(height: 48),
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
                              validator: Validatorless.required(
                                'Please enter your password',
                              ),
                            ),
                            const SizedBox(height: 16),
                            PaintProButton(
                              text: 'Login',
                              onPressed: viewModel.isLoading
                                  ? null
                                  : () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        viewModel.login(
                                          _emailController.text.toLowerCase(),
                                          _passwordController.text,
                                        );
                                      }
                                    },
                              isLoading: viewModel.isLoading,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(double.infinity, 48),
                            ),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  final email = _emailController.text
                                      .trim()
                                      .toLowerCase();

                                  if (email.isEmpty) {
                                    SnackBarUtils.showError(
                                      context,
                                      message:
                                          'Please enter your email to continue.',
                                    );
                                    return;
                                  }

                                  context.go('/verify-otp', extra: email);
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            if (viewModel.errorMessage != null)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: Text(
                                  viewModel.errorMessage!,
                                  style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24,
                      bottom: bottomInset + 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/signup');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 14,
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
