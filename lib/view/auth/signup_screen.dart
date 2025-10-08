import 'package:flutter/material.dart';
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
                                width: 100,
                                height: 100,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Center(
                              child: Text(
                                'Create Account',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                            const Center(
                              child: Text(
                                'Create your painting projects',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.gray100,
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
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
                            const SizedBox(height: 32),
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
                              minimumSize: const Size(double.infinity, 48),
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
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 0),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Login',
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
