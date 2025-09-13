import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../helpers/snackbar_helper.dart';
import '../../utils/result/result.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_number_field.dart';
import '../../widgets/form_field/paint_pro_text_field.dart';
import '../../widgets/overlays/loading_overlay.dart';
import '../../widgets/section_title_widget.dart';

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  // Controllers for form fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _adtionalPhonesController = TextEditingController();
  final _adtionalEmailsController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();
  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ViewModel
  late final ContactDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ContactDetailViewModel>();
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {
        // UI will be rebuilt with updated ViewModel state
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _adtionalPhonesController.dispose();
    _adtionalEmailsController.dispose();
    _emailController.dispose();
    _companyNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final viewModel = _viewModel;

    // Create custom fields for additional data
    final customFields = <Map<String, dynamic>>[];

    final result = await viewModel.createContact(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      additionalEmails: _adtionalEmailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      phone: _phoneController.text.trim(),
      additionalPhones: _adtionalPhonesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      address: _addressController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      postalCode: _zipCodeController.text.trim(),
      country: _countryController.text.trim(),
      companyName: _companyNameController.text.trim(),
      customFields: customFields.isNotEmpty ? customFields : null,
    );

    if (result is Ok) {
      // Show success message
      if (mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: 'Contact saved successfully!',
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    } else {
      // Show user-friendly error message
      if (mounted) {
        SnackBarHelper.showError(
          context,
          message:
              viewModel.error ?? 'Failed to save contact. Please try again.',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _viewModel.isLoading,
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
                    label: 'Name: *',
                    hintText: 'John Demnize',
                    controller: _nameController,
                    validator: Validatorless.multiple(
                      [
                        Validatorless.required('Name is required'),
                        Validatorless.min(
                          2,
                          'Name must be at least 2 characters',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Section
                  const SectionTitleWidget(title: 'Contact'),
                  const SizedBox(height: 16),

                  PaintProNumberField(
                    label: 'Phone: *',
                    hintText: '(555) 123-4567',
                    controller: _phoneController,
                    kind: NumberFieldKind.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone is required';
                      }

                      // Remove all non-digit characters for validation
                      final digitsOnly = value.replaceAll(
                        RegExp(r'[^\d]'),
                        '',
                      );

                      // Check if it's a valid phone number (at least 7 digits)
                      if (digitsOnly.length >= 7) {
                        return null;
                      } else {
                        return 'Please enter a valid phone number (at least 7 digits)';
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  PaintProNumberField(
                    label: 'Additional Phones:',
                    hintText: '(555) 123-4567, (555) 123-4589',
                    controller: _adtionalPhonesController,
                    kind: NumberFieldKind.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;

                      final phones = value
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty);

                      for (final phone in phones) {
                        // Remove all non-digit characters for validation
                        final digitsOnly = phone.replaceAll(
                          RegExp(r'[^\d]'),
                          '',
                        );

                        // Check if it's a valid phone number (at least 7 digits)
                        if (digitsOnly.length < 7) {
                          return 'Please enter valid phone numbers separated by commas (at least 7 digits each)';
                        }
                      }
                      return null;
                    },
                  ),

                  PaintProTextField(
                    label: 'Email: *',
                    hintText: 'example@mail.com',
                    controller: _emailController,
                    validator: Validatorless.multiple(
                      [
                        Validatorless.required('Email is required'),
                        Validatorless.email(
                          'Please enter a valid email',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'Adtional Emails:',
                    hintText: 'example@mail.com, example2@mail.com',
                    controller: _adtionalEmailsController,
                    validator: (value) {
                      if (value == null || value.isEmpty) return null;
                      final emails = value
                          .split(',')
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty);
                      for (final email in emails) {
                        final emailValidator = Validatorless.email(
                          'Invalid email address',
                        );
                        if (emailValidator(email) != null) {
                          return 'Please enter valid email addresses separated by commas';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const SectionTitleWidget(
                    title: 'Business Information',
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'Company Name:',
                    hintText: 'Painter Estimator LTDA',
                    controller: _companyNameController,
                    validator: Validatorless.multiple([
                      Validatorless.required('Company Name is required'),
                      Validatorless.min(
                        3,
                        'Company Name must be at least 3 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'Address: *',
                    hintText: '123 Main Street',
                    controller: _addressController,
                    validator: Validatorless.multiple([
                      Validatorless.required('Address is required'),
                      Validatorless.min(
                        3,
                        'Address must be at least 3 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'City: *',
                    hintText: 'Any City',
                    controller: _cityController,
                    validator: Validatorless.multiple([
                      Validatorless.required('City is required'),
                      Validatorless.min(
                        3,
                        'City must be at least 3 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'State: *',
                    hintText: 'Any State',
                    controller: _stateController,
                    validator: Validatorless.multiple([
                      Validatorless.required('State is required'),
                      Validatorless.min(
                        3,
                        'State must be at least 3 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  PaintProTextField(
                    label: 'Postal Code: *',
                    hintText: '12345',
                    controller: _zipCodeController,
                    validator: Validatorless.multiple([
                      Validatorless.required('Postal Code is required'),
                      Validatorless.min(
                        3,
                        'Postal Code must be at least 3 characters',
                      ),
                    ]),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  PaintProTextField(
                    label: 'Country: *',
                    hintText: 'Brazil',
                    controller: _countryController,
                    validator: Validatorless.multiple([
                      Validatorless.required('Country is required'),
                      Validatorless.min(
                        2,
                        'Country must be at least 2 characters',
                      ),
                    ]),
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
            text: _viewModel.isLoading ? 'Saving...' : 'Save',
            onPressed: _viewModel.isLoading ? null : _saveContact,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
