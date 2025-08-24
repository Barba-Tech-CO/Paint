import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_colors.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../widgets/appbars/paint_pro_app_bar.dart';
import '../widgets/form_field/paint_pro_number_field.dart';
import '../widgets/form_field/paint_pro_text_field.dart';
import '../widgets/overlays/error_overlay.dart';
import '../widgets/overlays/loading_overlay.dart';
import '../widgets/section_title_widget.dart';

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  // Controllers for form fields
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _phoneLabelController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _sourceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _phoneLabelController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _cityController.dispose();
    _companyNameController.dispose();
    _businessNameController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _typeController.dispose();
    _sourceController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = context.read<ContactDetailViewModel>();

    // Create custom fields for additional data
    final customFields = <Map<String, dynamic>>[];

    if (_phoneLabelController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'phoneLabel',
        'value': _phoneLabelController.text.trim(),
      });
    }

    if (_businessNameController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'businessName',
        'value': _businessNameController.text.trim(),
      });
    }

    if (_zipcodeController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'postalCode',
        'value': _zipcodeController.text.trim(),
      });
    }

    if (_cityController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'city',
        'value': _cityController.text.trim(),
      });
    }

    if (_stateController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'state',
        'value': _stateController.text.trim(),
      });
    }

    if (_countryController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'country',
        'value': _countryController.text.trim(),
      });
    }

    if (_typeController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'type',
        'value': _typeController.text.trim(),
      });
    }

    if (_sourceController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'source',
        'value': _sourceController.text.trim(),
      });
    }

    if (_tagsController.text.trim().isNotEmpty) {
      customFields.add({
        'name': 'tags',
        'value': _tagsController.text
            .trim()
            .split(',')
            .map((e) => e.trim())
            .toList(),
      });
    }

    final success = await viewModel.createContact(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      companyName: _companyNameController.text.trim(),
      address: _addressController.text.trim(),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaintProAppBar(title: 'New Contact'),
      body: Consumer<ContactDetailViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return const LoadingOverlay(
              isLoading: true,
              child: SizedBox(),
            );
          }

          if (viewModel.error != null) {
            return ErrorOverlay(
              error: viewModel.error!,
              onRetry: () {
                viewModel.clearError();
              },
            );
          }

          return SingleChildScrollView(
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
                      label: 'First Name *',
                      hintText: 'Enter first name',
                      controller: _firstNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Last Name *',
                      hintText: 'Enter last name',
                      controller: _lastNameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),

                    // Contact Section
                    const SectionTitleWidget(title: 'Contact'),
                    const SizedBox(height: 16),

                    PaintProNumberField(
                      label: 'Phone',
                      hintText: '(555) 123-4567',
                      controller: _phoneController,
                      kind: NumberFieldKind.phone,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Phone Label',
                      hintText: 'Mobile, Work, Home',
                      controller: _phoneLabelController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Email *',
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

                    // Location Section
                    const SectionTitleWidget(title: 'Location'),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Address',
                      hintText: '1243 New Orlando',
                      controller: _addressController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'City',
                      hintText: 'Dallas',
                      controller: _cityController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'State',
                      hintText: 'Texas',
                      controller: _stateController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Country',
                      hintText: 'USA',
                      controller: _countryController,
                    ),

                    const SizedBox(height: 16),

                    PaintProNumberField(
                      label: 'Postal Code',
                      hintText: '12345',
                      controller: _zipcodeController,
                      kind: NumberFieldKind.zip,
                    ),

                    // Business Information Section
                    const SectionTitleWidget(title: 'Business Information'),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Company Name',
                      hintText: 'Paint Estimator LTDA',
                      controller: _companyNameController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Business Name',
                      hintText: 'Alternative business name',
                      controller: _businessNameController,
                    ),

                    // Additional Information Section
                    const SectionTitleWidget(title: 'Additional Information'),
                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Contact Type',
                      hintText: 'Customer, Lead, Vendor',
                      controller: _typeController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Source',
                      hintText: 'Website, Referral, Cold Call',
                      controller: _sourceController,
                    ),

                    const SizedBox(height: 16),

                    PaintProTextField(
                      label: 'Tags',
                      hintText: 'VIP, Priority, Follow-up (comma separated)',
                      controller: _tagsController,
                    ),

                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModel.isLoading ? null : _saveContact,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: viewModel.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.textOnPrimary,
                                  ),
                                ),
                              )
                            : const Text(
                                'Save Contact',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
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
