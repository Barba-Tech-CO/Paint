import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:validatorless/validatorless.dart';

import '../../config/dependency_injection.dart';
import '../../helpers/snackbar_helper.dart';
import '../../utils/result/result.dart';
import '../../viewmodel/contact/contact_detail_viewmodel.dart';

class NewContactHelper {
  static final ContactDetailViewModel _viewModel =
      getIt<ContactDetailViewModel>();

  /// Validates phone number format
  static String? validatePhone(String? value) {
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
  }

  /// Validates additional phones format
  static String? validateAdditionalPhones(String? value) {
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
  }

  /// Validates additional emails format
  static String? validateAdditionalEmails(String? value) {
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
  }

  /// Gets name validation rules
  static String? Function(String?) get nameValidator => Validatorless.multiple([
    Validatorless.required('Name is required'),
    Validatorless.min(2, 'Name must be at least 2 characters'),
  ]);

  /// Gets email validation rules
  static String? Function(String?) get emailValidator =>
      Validatorless.multiple([
        Validatorless.required('Email is required'),
        Validatorless.email('Please enter a valid email'),
      ]);

  /// Gets company name validation rules
  static String? Function(String?) get companyNameValidator =>
      Validatorless.multiple([
        Validatorless.required('Company Name is required'),
        Validatorless.min(3, 'Company Name must be at least 3 characters'),
      ]);

  /// Gets address validation rules
  static String? Function(String?) get addressValidator =>
      Validatorless.multiple([
        Validatorless.required('Address is required'),
        Validatorless.min(3, 'Address must be at least 3 characters'),
      ]);

  /// Gets city validation rules
  static String? Function(String?) get cityValidator => Validatorless.multiple([
    Validatorless.required('City is required'),
    Validatorless.min(3, 'City must be at least 3 characters'),
  ]);

  /// Gets state validation rules
  static String? Function(String?) get stateValidator =>
      Validatorless.multiple([
        Validatorless.required('State is required'),
        Validatorless.min(3, 'State must be at least 3 characters'),
      ]);

  /// Gets postal code validation rules
  static String? Function(String?) get postalCodeValidator =>
      Validatorless.multiple([
        Validatorless.required('Postal Code is required'),
        Validatorless.min(3, 'Postal Code must be at least 3 characters'),
      ]);

  /// Gets country validation rules
  static String? Function(String?) get countryValidator =>
      Validatorless.multiple([
        Validatorless.required('Country is required'),
        Validatorless.min(2, 'Country must be at least 2 characters'),
      ]);

  /// Saves a new contact
  static Future<void> saveContact({
    required GlobalKey<FormState> formKey,
    required TextEditingController nameController,
    required TextEditingController emailController,
    required TextEditingController additionalEmailsController,
    required TextEditingController phoneController,
    required TextEditingController additionalPhonesController,
    required TextEditingController addressController,
    required TextEditingController cityController,
    required TextEditingController stateController,
    required TextEditingController zipCodeController,
    required TextEditingController countryController,
    required TextEditingController companyNameController,
    required BuildContext context,
  }) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    // Create custom fields for additional data
    final customFields = <Map<String, dynamic>>[];

    final result = await _viewModel.createContact(
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      additionalEmails: additionalEmailsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      phone: phoneController.text.trim(),
      additionalPhones: additionalPhonesController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList(),
      address: addressController.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      postalCode: zipCodeController.text.trim(),
      country: countryController.text.trim(),
      companyName: companyNameController.text.trim(),
      customFields: customFields.isNotEmpty ? customFields : null,
    );

    if (result is Ok) {
      // Show success message
      if (context.mounted) {
        SnackBarHelper.showSuccess(
          context,
          message: 'Contact saved successfully!',
        );

        // Navigate back after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (context.mounted) {
            context.pop();
          }
        });
      }
    } else {
      // Show user-friendly error message
      if (context.mounted) {
        SnackBarHelper.showError(
          context,
          message:
              _viewModel.error ?? 'Failed to save contact. Please try again.',
        );
      }
    }
  }
}
