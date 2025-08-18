import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/app_colors.dart';
import '../../../../view/widgets/widgets.dart';
import '../viewmodels/create_project_viewmodel.dart';
import '../../domain/entities/create_project_state.dart';
import '../../domain/entities/project_form.dart';

class CreateProjectView extends StatefulWidget {
  const CreateProjectView({super.key});

  @override
  State<CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<CreateProjectView> {
  final TextEditingController _clientNameController = TextEditingController();
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _additionalNotesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    
    // Set up listeners to sync with ViewModel
    _clientNameController.addListener(() {
      context.read<CreateProjectViewmodel>().updateClientName(_clientNameController.text);
    });
    
    _projectNameController.addListener(() {
      context.read<CreateProjectViewmodel>().updateProjectName(_projectNameController.text);
    });
    
    _additionalNotesController.addListener(() {
      context.read<CreateProjectViewmodel>().updateAdditionalNotes(_additionalNotesController.text);
    });
  }

  @override
  void dispose() {
    _clientNameController.dispose();
    _projectNameController.dispose();
    _additionalNotesController.dispose();
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
      body: Consumer<CreateProjectViewmodel>(
        builder: (context, viewModel, child) {
          final state = viewModel.state;
          
          // Show error snackbar if there's an error
          if (state.viewState == CreateProjectViewState.error && state.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
              viewModel.clearError();
            });
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                spacing: 12,
                children: [
                  const SizedBox.shrink(),

                  // Client Information Card
                  InputCardWidget(
                    title: 'Client Information',
                    description: 'Client Name*',
                    controller: _clientNameController,
                    hintText: 'John',
                    maxLines: 1,
                  ),

                  // Project Details Card
                  InputCardWidget(
                    title: 'Project Details',
                    description: 'Project Name *',
                    controller: _projectNameController,
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
                          children: ProjectType.values.map((type) {
                            return Row(
                              children: [
                                Radio<ProjectType>(
                                  value: type,
                                  groupValue: state.form.projectType,
                                  onChanged: (value) {
                                    if (value != null) {
                                      viewModel.updateProjectType(value);
                                    }
                                  },
                                  activeColor: AppColors.primary,
                                ),
                                Text(type.displayName),
                                const SizedBox(width: 16),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Additional Notes Card
                  InputCardWidget(
                    title: 'Additional Notes',
                    controller: _additionalNotesController,
                    hintText: 'Enter additional notes',
                    maxLines: 6,
                    multiline: true,
                  ),

                  // Next Button
                  Stack(
                    children: [
                      PaintProButton(
                        text: 'Next',
                        onPressed: !viewModel.isFormValid || state.viewState == CreateProjectViewState.saving
                            ? null
                            : () async {
                                final success = await viewModel.saveProject();
                                if (success && mounted) {
                                  if (context.mounted) {
                                    context.push('/camera');
                                  }
                                }
                              },
                      ),
                      if (state.viewState == CreateProjectViewState.saving)
                        Positioned.fill(
                          child: Container(
                            alignment: Alignment.center,
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}