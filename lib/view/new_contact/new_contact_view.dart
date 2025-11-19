import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../viewmodel/contact/new_contact_viewmodel.dart';
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
  late final NewContactViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<NewContactViewModel>();
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
    await _viewModel.saveContact(
      formKey: _formKey,
      nameController: _nameController,
      emailController: _emailController,
      additionalEmailsController: _adtionalEmailsController,
      phoneController: _phoneController,
      additionalPhonesController: _adtionalPhonesController,
      addressController: _addressController,
      cityController: _cityController,
      stateController: _stateController,
      zipCodeController: _zipCodeController,
      countryController: _countryController,
      companyNameController: _companyNameController,
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _viewModel.isLoading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PaintProAppBar(title: 'New Contact'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),

                  const SectionTitleWidget(title: 'Client Information'),
                  SizedBox(height: 16.h),

                  PaintProTextField(
                    label: 'Name: *',
                    hintText: 'John Demnize',
                    controller: _nameController,
                    validator: NewContactViewModel.nameValidator,
                  ),
                  SizedBox(height: 16.h),

                  // Contact Section
                  const SectionTitleWidget(title: 'Contact'),
                  SizedBox(height: 16.h),

                  PaintProNumberField(
                    label: 'Phone: *',
                    hintText: '+1 (555) 123-4567',
                    controller: _phoneController,
                    kind: NumberFieldKind.phone,
                    validator: NewContactViewModel.validatePhone,
                  ),
                  SizedBox(height: 16.h),
                  PaintProNumberField(
                    label: 'Additional Phones:',
                    hintText: '+1 (555) 123-4567, +1 (555) 123-4589',
                    controller: _adtionalPhonesController,
                    kind: NumberFieldKind.phone,
                    validator: NewContactViewModel.validateAdditionalPhones,
                  ),

                  PaintProTextField(
                    label: 'Email: *',
                    hintText: 'example@mail.com',
                    controller: _emailController,
                    validator: NewContactViewModel.emailValidator,
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'Adtional Emails:',
                    hintText: 'example@mail.com, example2@mail.com',
                    controller: _adtionalEmailsController,
                    validator: NewContactViewModel.validateAdditionalEmails,
                  ),
                  SizedBox(height: 16.h),

                  const SectionTitleWidget(
                    title: 'Business Information',
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'Company Name:',
                    hintText: 'Painter Estimator LTDA',
                    controller: _companyNameController,
                    validator: NewContactViewModel.companyNameValidator,
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'Address: *',
                    hintText: '123 Main Street',
                    controller: _addressController,
                    validator: NewContactViewModel.addressValidator,
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'City: *',
                    hintText: 'Any City',
                    controller: _cityController,
                    validator: NewContactViewModel.cityValidator,
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'State: *',
                    hintText: 'Any State',
                    controller: _stateController,
                    validator: NewContactViewModel.stateValidator,
                  ),
                  SizedBox(height: 16.h),
                  PaintProTextField(
                    label: 'Postal Code: *',
                    hintText: '12345',
                    controller: _zipCodeController,
                    validator: NewContactViewModel.postalCodeValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Country: *',
                    hintText: 'Brazil',
                    controller: _countryController,
                    validator: NewContactViewModel.countryValidator,
                  ),
                  // Add some bottom padding to ensure content is not hidden by bottomNavigationBar
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(16.w),
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
