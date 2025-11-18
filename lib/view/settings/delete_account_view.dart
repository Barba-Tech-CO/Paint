import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/auth/delete_account_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_password_field.dart';
import '../../widgets/banners/delete_account_warning_banner.dart';
import '../../widgets/lists/delete_account_items_list.dart';
import '../../widgets/dialogs/confirmation_dialog_widget.dart';

class DeleteAccountView extends StatefulWidget {
  const DeleteAccountView({super.key});

  @override
  State<DeleteAccountView> createState() => _DeleteAccountViewState();
}

class _DeleteAccountViewState extends State<DeleteAccountView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<DeleteAccountViewModel>(),
      child: Consumer<DeleteAccountViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.deletionSuccess) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                context.go('/auth');
              }
            });
          }

          if (viewModel.showConfirmation) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              final confirmed = await ConfirmationDialogWidget.show(
                context,
                title: 'Delete Account?',
                message:
                    'This action cannot be undone. All your data will be permanently deleted.',
                confirmText: 'Delete',
                cancelText: 'Cancel',
                isDestructive: true,
              );

              if (mounted) {
                if (confirmed) {
                  viewModel.confirmDeleteAccount();
                } else {
                  viewModel.cancelDeletion();
                }
              }
            });
          }

          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: PaintProAppBar(
              title: 'Delete Account',
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textOnPrimary,
                ),
                onPressed: viewModel.isLoading ? null : () => context.pop(),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DeleteAccountWarningBanner(),
                    const SizedBox(height: 24),
                    const DeleteAccountItemsList(),
                    const SizedBox(height: 32),
                    Text(
                      'Enter your password to confirm',
                      style: GoogleFonts.albertSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PaintProPasswordField(
                      label: 'Password:',
                      controller: _passwordController,
                      hintText: 'Enter your password',
                      isEnabled: !viewModel.isLoading,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    if (viewModel.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        viewModel.errorMessage!,
                        style: GoogleFonts.albertSans(
                          fontSize: 12,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    PaintProButton(
                      onPressed: viewModel.isLoading
                          ? null
                          : () {
                              if (_formKey.currentState!.validate()) {
                                viewModel.requestDeleteAccount(
                                  _passwordController.text,
                                );
                              }
                            },
                      text: viewModel.isLoading
                          ? 'Deleting Account...'
                          : 'Delete My Account',
                      minimumSize: const Size(double.infinity, 48),
                      backgroundColor: AppColors.error,
                      state: viewModel.isLoading
                          ? ButtonState.loading
                          : ButtonState.enabled,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: viewModel.isLoading
                            ? null
                            : () => context.pop(),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.albertSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
