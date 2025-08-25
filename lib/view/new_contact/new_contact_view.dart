import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';
import '../widgets/form_field/paint_pro_number_field.dart';
import '../widgets/form_field/paint_pro_text_field.dart';
import '../widgets/overlays/loading_overlay.dart';
import '../widgets/section_title_widget.dart';
import '../widgets/widgets.dart';

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ContactDetailViewModel>();

    // Create custom fields for additional data
    final customFields = <Map<String, dynamic>>[];

    final success = await viewModel.createContact(
      firstName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      companyName: _companyNameController.text.trim(),
      customFields: customFields.isNotEmpty ? customFields : null,
    );

    if (success && mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contact saved successfully!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate back
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactDetailViewModel>(
      builder: (context, viewModel, child) {
        return LoadingOverlay(
          isLoading: viewModel.isLoading,
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: const PaintProAppBar(title: 'New Contact'),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const SectionTitleWidget(title: 'Client Information'),
                      const SizedBox(height: 16),

                      PaintProTextField(
                        label: 'Name:',
                        hintText: 'John',
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contact Section
                      const SectionTitleWidget(title: 'Contact'),
                      const SizedBox(height: 16),

                      PaintProNumberField(
                        label: 'Phone:',
                        hintText: '(555) 123-4567',
                        controller: _phoneController,
                        kind: NumberFieldKind.phone,
                      ),

                      PaintProTextField(
                        label: 'Email:',
                        hintText: 'example@mail.com',
                        controller: _emailController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Email is required';
                          }
                          if (!RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          ).hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Business Information Section
                      const SectionTitleWidget(title: 'Additional Information'),

                      PaintProTextField(
                        label: 'Company Name:',
                        hintText: 'Painter Pro LTDA',
                        controller: _companyNameController,
                      ),

                      // Add some bottom padding to ensure content is not hidden by bottomNavigationBar
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: const EdgeInsets.all(16),
              child: PaintProButton(
                text: viewModel.isLoading ? 'Saving...' : 'Save',
                onPressed: viewModel.isLoading ? null : _saveContact,
                borderRadius: 16,
              ),
            ),
          ),
        );
      },
    );
  }
}
