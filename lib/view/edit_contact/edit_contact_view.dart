import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../config/app_colors.dart';
import '../../config/dependency_injection.dart';
import '../../model/contacts/contact_model.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';
import '../../widgets/appbars/paint_pro_app_bar.dart';
import '../../widgets/buttons/paint_pro_button.dart';
import '../../widgets/form_field/paint_pro_number_field.dart';
import '../../widgets/form_field/paint_pro_text_field.dart';
import '../../widgets/section_title_widget.dart';

class EditContactView extends StatefulWidget {
  final ContactModel contact;

  const EditContactView({
    super.key,
    required this.contact,
  });

  @override
  State<EditContactView> createState() => _EditContactViewState();
}

class _EditContactViewState extends State<EditContactView> {
  // Controllers for form fields
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _adtionalPhonesController;
  late final TextEditingController _adtionalEmailsController;
  late final TextEditingController _emailController;
  late final TextEditingController _companyNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _zipCodeController;
  late final TextEditingController _countryController;

  // Form key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ViewModel
  late final ContactDetailViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = getIt<ContactDetailViewModel>();
    _viewModel.addListener(_onViewModelChanged);
    _initializeControllers();
    _populateFormWithContactData();
  }

  void _onViewModelChanged() {
    if (mounted) {
      setState(() {
        // UI will be rebuilt with updated ViewModel state
      });
    }
  }

  void _initializeControllers() {
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _adtionalPhonesController = TextEditingController();
    _adtionalEmailsController = TextEditingController();
    _emailController = TextEditingController();
    _companyNameController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _zipCodeController = TextEditingController();
    _countryController = TextEditingController();
  }

  void _populateFormWithContactData() {
    _viewModel.populateFormWithContactData(
      contact: widget.contact,
      nameController: _nameController,
      phoneController: _phoneController,
      additionalPhonesController: _adtionalPhonesController,
      additionalEmailsController: _adtionalEmailsController,
      emailController: _emailController,
      companyNameController: _companyNameController,
      addressController: _addressController,
      cityController: _cityController,
      stateController: _stateController,
      zipCodeController: _zipCodeController,
      countryController: _countryController,
    );
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

  Future<void> _updateContact() async {
    await _viewModel.updateContactWithForm(
      formKey: _formKey,
      contact: widget.contact,
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
    return GestureDetector(
      onTap: () {
        // Close keyboard when tapping outside text fields
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: PaintProAppBar(title: 'Edit Contact'),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 16.h,
                  ),
                  const SectionTitleWidget(
                    title: 'Client Information',
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Name: *',
                    hintText: 'John Demnize',
                    controller: _nameController,
                    validator: ContactDetailViewModel.nameValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  // Contact Section
                  const SectionTitleWidget(title: 'Contact'),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProNumberField(
                    label: 'Phone: *',
                    hintText: '+1 (555) 123-4567',
                    controller: _phoneController,
                    kind: NumberFieldKind.phone,
                    validator: ContactDetailViewModel.validatePhone,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProNumberField(
                    label: 'Additional Phones:',
                    hintText: '+1 (555) 123-4567, +1 (555) 123-4589',
                    controller: _adtionalPhonesController,
                    kind: NumberFieldKind.phone,
                    validator: ContactDetailViewModel.validateAdditionalPhones,
                  ),
                  PaintProTextField(
                    label: 'Email: *',
                    hintText: 'example@mail.com',
                    controller: _emailController,
                    validator: ContactDetailViewModel.emailValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Adtional Emails:',
                    hintText: 'example@mail.com, example2@mail.com',
                    controller: _adtionalEmailsController,
                    validator: ContactDetailViewModel.validateAdditionalEmails,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  const SectionTitleWidget(
                    title: 'Business Information',
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Company Name:',
                    hintText: 'Painter Estimator LTDA',
                    controller: _companyNameController,
                    validator: ContactDetailViewModel.companyNameValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Address: *',
                    hintText: '123 Main Street',
                    controller: _addressController,
                    validator: ContactDetailViewModel.addressValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'City: *',
                    hintText: 'Any City',
                    controller: _cityController,
                    validator: ContactDetailViewModel.cityValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'State: *',
                    hintText: 'Any State',
                    controller: _stateController,
                    validator: ContactDetailViewModel.stateValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProNumberField(
                    label: 'Postal Code: *',
                    hintText: '12345',
                    controller: _zipCodeController,
                    kind: NumberFieldKind.zip,
                    textInputAction: TextInputAction.done,
                    validator: ContactDetailViewModel.postalCodeValidator,
                  ),
                  SizedBox(
                    height: 16.h,
                  ),
                  PaintProTextField(
                    label: 'Country: *',
                    hintText: 'US',
                    controller: _countryController,
                    validator: ContactDetailViewModel.countryValidator,
                  ),
                  // Add some bottom padding to ensure content is not hidden by bottomNavigationBar
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.all(
            16.w,
          ),
          child: PaintProButton(
            text: _viewModel.isLoading ? 'Updating...' : 'Update',
            onPressed: _viewModel.isLoading ? null : _updateContact,
            borderRadius: 16,
          ),
        ),
      ),
    );
  }
}
