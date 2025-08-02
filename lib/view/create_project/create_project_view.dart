import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paintpro/config/app_colors.dart';
import 'package:paintpro/view/widgets/appbars/paint_pro_app_bar.dart';
<<<<<<< HEAD:lib/view/new_project/new_project_view.dart
import 'package:paintpro/view/widgets/buttons/paint_pro_button.dart';
=======
import 'package:paintpro/view/widgets/buttons/primary_button_widget.dart';
>>>>>>> 96e0f9b58a105602ca2e293fe43a943e4a3f7e9b:lib/view/create_project/create_project_view.dart
import 'package:paintpro/view/widgets/cards/input_card_widget.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _projectDetailsController =
      TextEditingController();
  final TextEditingController _additionalNotesController =
      TextEditingController();

  // Estado para controlar a seleção do tipo de projeto
  String _selectedProjectType = '';

  bool get _isFormValid {
    return _projectNameController.text.trim().isNotEmpty &&
        _projectDetailsController.text.trim().isNotEmpty;
  }

  @override
  void dispose() {
    _projectNameController.dispose();
    _additionalNotesController.dispose();
    _projectDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PaintProAppBar(
        title: 'New Project',
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 12,
            children: [
              const SizedBox.shrink(),

              // Card de Notas Adicionais
              InputCardWidget(
                title: 'Client Information',
                description: 'Client Name*',
                controller: _projectNameController,
                hintText: 'John',
                maxLines: 1,
              ),

              InputCardWidget(
                title: 'Project Details',
                description: 'Project Name *',
                controller: _projectDetailsController,
                hintText: 'Enter project name',
                widget: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Project Type *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 'Interior',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Interior'),

                        const SizedBox(width: 16),

                        Radio(
                          value: 'Exterior',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Exterior'),

                        const SizedBox(width: 16),

                        Radio(
                          value: 'Both',
                          groupValue: _selectedProjectType,
                          onChanged: (value) {
                            setState(() {
                              _selectedProjectType = value.toString();
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        Text('Both'),
                      ],
                    ),
                  ],
                ),
              ),

              InputCardWidget(
                title: 'Additional Notes',
                controller: _additionalNotesController,
                hintText: 'Enter additional notes',
                maxLines: 6,
                multiline: true,
              ),

              PaintProButton(
                text: 'Next',
                onPressed: !_isFormValid ? null : () => context.push('/camera'),
              ),
             
            ],
          ),
        ),
      ),
    );
  }
}
