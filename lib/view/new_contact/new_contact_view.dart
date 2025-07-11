import 'package:flutter/material.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
import 'package:paintpro/view/widgets/form_field/paint_pro_form_field.dart';
import 'package:paintpro/config/app_colors.dart';

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

  // Dropdown values
  String? _selectedName;
  String? _selectedCountry;
  String? _selectedState;

  @override
  void dispose() {
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _zipcodeController.dispose();
    _cityController.dispose();
    _companyNameController.dispose();
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

              PaintProFormField.dropdown(
                label: 'Name:',
                items: [
                  const DropdownMenuItem(value: 'John', child: Text('John')),
                  const DropdownMenuItem(value: 'Sarah', child: Text('Sarah')),
                  const DropdownMenuItem(
                    value: 'Michael',
                    child: Text('Michael'),
                  ),
                  const DropdownMenuItem(
                    value: 'Amanda',
                    child: Text('Amanda'),
                  ),
                ],
                value: _selectedName,
                onChanged: (value) {
                  setState(() {
                    _selectedName = value;
                  });
                },
              ),

              // Contact Section
              _buildSectionTitle('Contact'),
              const SizedBox(height: 16),

              PaintProFormField.phone(
                label: 'Phone:',
                hintText: '+1 38 785-2948',
                controller: _phoneController,
              ),

              PaintProFormField.text(
                label: 'Email:',
                hintText: 'example@mail.com',
                controller: _emailController,
              ),

              // Location Section
              _buildSectionTitle('Location'),
              const SizedBox(height: 16),

              PaintProFormField.text(
                label: 'Address:',
                hintText: '1243 New orlando',
                controller: _addressController,
              ),

              PaintProFormField.number(
                label: 'Zipcode:',
                hintText: '45859934',
                controller: _zipcodeController,
              ),

              PaintProFormField.dropdown(
                label: 'Country:',
                items: [
                  const DropdownMenuItem(value: 'USA', child: Text('USA')),
                  const DropdownMenuItem(
                    value: 'Canada',
                    child: Text('Canada'),
                  ),
                  const DropdownMenuItem(
                    value: 'Brazil',
                    child: Text('Brazil'),
                  ),
                  const DropdownMenuItem(
                    value: 'Mexico',
                    child: Text('Mexico'),
                  ),
                ],
                value: _selectedCountry,
                hintText: 'USA',
                onChanged: (value) {
                  setState(() {
                    _selectedCountry = value;
                  });
                },
              ),

              PaintProFormField.dropdown(
                label: 'State:',
                items: [
                  const DropdownMenuItem(value: 'Texas', child: Text('Texas')),
                  const DropdownMenuItem(
                    value: 'California',
                    child: Text('California'),
                  ),
                  const DropdownMenuItem(
                    value: 'New York',
                    child: Text('New York'),
                  ),
                  const DropdownMenuItem(
                    value: 'Florida',
                    child: Text('Florida'),
                  ),
                ],
                value: _selectedState,
                hintText: 'Texas',
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                  });
                },
              ),

              PaintProFormField.text(
                label: 'City:',
                hintText: 'Dallas',
                controller: _cityController,
              ),

              // Additional Information Section
              _buildSectionTitle('Additional Information'),
              const SizedBox(height: 16),

              PaintProFormField.text(
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
