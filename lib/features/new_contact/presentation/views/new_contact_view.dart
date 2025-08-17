import 'package:flutter/material.dart';

import '../../../../config/app_colors.dart';
import '../../../../view/widgets/appbars/paint_pro_app_bar.dart';
import '../../../../view/widgets/form_field/paint_pro_number_field.dart';
import '../../../../view/widgets/form_field/paint_pro_text_field.dart';

class NewContactView extends StatefulWidget {
  const NewContactView({super.key});

  @override
  State<NewContactView> createState() => _NewContactViewState();
}

class _NewContactViewState extends State<NewContactView> {
  // Controllers for form fields
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _zipcodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  // Dropdown values
  String? _selectedName;
  // String? _selectedCountry;
  // String? _selectedState;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _cityController.dispose();
    _companyNameController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _saveContact() {
    // TODO: Implement save contact logic
    // This will be connected to the ContactViewModel later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contact saved successfully!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const PaintProAppBar(title: 'New Contact'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildSectionTitle('Client Information'),
              const SizedBox(height: 16),

              PaintProTextField(
                label: 'Name',
                hintText: 'Enter client name',
                onChanged: (value) {
                  setState(() {
                    _selectedName = value;
                  });
                },
              ),

              // Contact Section
              _buildSectionTitle('Contact'),
              const SizedBox(height: 16),

              PaintProNumberField(
                label: 'Phone:',
                hintText: '+1 38 785-2948',
                controller: _phoneController,
              ),

              PaintProTextField(
                label: 'Email:',
                hintText: 'example@mail.com',
                controller: _emailController,
              ),

              // Location Section
              _buildSectionTitle('Location'),
              const SizedBox(height: 16),

              PaintProTextField(
                label: 'Address:',
                hintText: '1243 New orlando',
                controller: _addressController,
              ),

              PaintProNumberField(
                label: 'Zipcode:',
                hintText: '45859934',
                controller: _zipcodeController,
              ),

              PaintProTextField(
                label: 'Country:',
                hintText: 'EUA',
                controller: _countryController,
              ),

              PaintProTextField(
                label: 'State:',
                hintText: 'Texas',
                controller: _stateController,
              ),

              PaintProTextField(
                label: 'City:',
                hintText: 'Dallas',
                controller: _cityController,
              ),

              // Additional Information Section
              _buildSectionTitle('Additional Information'),
              const SizedBox(height: 16),

              PaintProTextField(
                label: 'Company Name:',
                hintText: 'Painter Pro LTDA',
                controller: _companyNameController,
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveContact,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
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
  }

  //TODO: Vou remover isso depois
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}